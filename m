From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6.0: something is leaking memory
Date: Sun, 4 Jan 2004 20:48:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040104204834.40b6ca51.davem@redhat.com>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net>
	<Pine.LNX.4.58.0401041257290.2162@home.osdl.org>
	<slrnbvh1hd.jl6.erik@dexter.hensema.net>
	<Pine.LNX.4.58.0401041826400.2162@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: erik@hensema.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401041826400.2162@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 4 Jan 2004 18:30:21 -0800 (PST)
Linus Torvalds <torvalds@osdl.org> wrote:

> You've got 19 _megabytes_ allocated to "tcp6_sock", and they are all 
> marked as "active". That's almost certainly the leaking bug.
> 
> Everything else looks reasonably normal.
 ...
> David?

Fixed by changeset 1.1496.16.1 which is in 2.6.1-rc1
