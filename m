From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 11:58:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819115845.4e968506.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5F@post.pc.aspectgroup.co.uk>
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
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB5F@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 20:00:44 +0100
Richard Underwood <richard@aspectgroup.co.uk> wrote:

> David S. Miller wrote: 
> > If I know that IP X has my configuration information, I
> > have every right to send X a packet from zero-net to
> > ask for that information before I have any IP addresses
> > attached to the interface.
> > 
> 	Ick! And how is IP X going to get the information back?

It knows the MAC address of the intended receiver, there is
no problem here.

> 	If you are going to send from 0.0.0.0, then I assume there's
> something in the ARP standard to say "don't cache this ARP request" - I must
> have missed it. If so, that's a special case - no need to spoil things
> elsewhere, though.

What is the caching problem?  The ARP response is valid, and we
have no reason to believe otherwise.

> 	Well, what do you do currently? If the packet you're routeing came
> from another host, there's no way in hell you can use their IP address in an
> ARP request ... is there? I certainly hope you don't go that far!!!

We're not talking about routing scenerios, we're talking strictly
about packets being originated by an application on the local host.

> > Besides normal IP addresses, multicast tools use these
> > facilities.
> > 
> 	Multicast uses ARP? That's news to me!

It uses routes that only have been determined only using the desired
device index.  There is no "interface address" to match up to when
we're trying to send to a multicast address.
