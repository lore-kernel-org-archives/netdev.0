From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 09:51:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819095105.2cb9acc1.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5B@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: skraw@ithnet.com, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Underwood <richard@aspectgroup.co.uk>
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB5B@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 17:54:26 +0100
Richard Underwood <richard@aspectgroup.co.uk> wrote:

> 	When a HOST sends out an ARP request, it's NOT associated with a
> single connection, it's associated with the host. Why should it pick a
> "random" IP number to send as the source address?

It's not "random", it is using the IP address it intends
to use as the source in packets it will output once the
ARP completes.

In fact, if you look at the code in arp_solicit(), the source address
is coming directly from the packet we are trying to output.
