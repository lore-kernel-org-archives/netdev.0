From: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 20:30:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <089d01c36680$09c04b30$c801a8c0@llewella>
References: <353568DCBAE06148B70767C1B1A93E625EAB5E@post.pc.aspectgroup.co.uk> <20030819111358.35ef1059.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <skraw@ithnet.com>, <willy@w.ods.org>, <alan@lxorguk.ukuu.org.uk>,
   <carlosev@newipnet.com>, <lamont@scriptkiddie.org>, <davidsen@tmr.com>,
   <marcelo@conectiva.com.br>, <netdev@oss.sgi.com>,
   <linux-net@vger.kernel.org>, <layes@loran.com>, <torvalds@osdl.org>,
   <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   "Richard Underwood" <richard@aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > Ok, then how would you propose to be able to send
> > > packets out an interface _before_ we have addresses
> > > assigned to it?
> > >
> > IP packets you mean? You don't? ;) It would depend on why you're
> > doing it naturally. Mostly, I'd have thought that if a host doesn't have
an
> > IP number it doesn't get to use ARP.
>
> Of course it gets to use ARP, nothing prevents this.
Huh? RFC 826 states that the requesting arp packet sends the protocol
address of itself. So no address is no arp.

Allowing it to is a violation of that rfc

Regards,
Bas
