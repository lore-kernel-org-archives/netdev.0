From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 11:13:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819111358.35ef1059.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5E@post.pc.aspectgroup.co.uk>
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
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB5E@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 19:16:18 +0100
Richard Underwood <richard@aspectgroup.co.uk> wrote:

> David S. Miller wrote:
> > Ok, then how would you propose to be able to send
> > packets out an interface _before_ we have addresses
> > assigned to it?
> > 
> 	IP packets you mean? You don't? ;) It would depend on why you're
> doing it naturally. Mostly, I'd have thought that if a host doesn't have an
> IP number it doesn't get to use ARP.

Of course it gets to use ARP, nothing prevents this.

If I know that IP X has my configuration information, I
have every right to send X a packet from zero-net to
ask for that information before I have any IP addresses
attached to the interface.

This is nothing wrong nor strange about this and we've
supported it for years.

Also, when one specifies a specific device in an output
address and we cannot find the IP part of the address
in the routing tables, we still procure a valid route for
the requester.

Besides normal IP addresses, multicast tools use these
facilities.
