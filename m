From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH-2.6.0-tiny] "uninline" {lock,release}_sock
Date: Sun, 28 Dec 2003 01:23:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031228012329.43003de5.davem@redhat.com>
References: <20031228075426.GB24351@conectiva.com.br>
	<Pine.LNX.4.58.0312280017060.2274@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, mpm@selenic.com, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0312280017060.2274@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 28 Dec 2003 00:23:07 -0800 (PST)
Linus Torvalds <torvalds@osdl.org> wrote:

> Function calls aren't all that expensive, especially with FASTCALL() etc 
> to show that you don't have to follow the common calling conventions. 
> Right now I think FASTCALL() only matters on x86, but some other 
> architectures could make it mean "smaller call clobbered list" or similar.
> 
> Have you benchmarked with the smaller kernel? 

To be honest I think {lock,release}_sock() should both be uninlined
always.

It almost made sense to inline these things before the might_sleep()
was added, now it definitely makes no sense.
