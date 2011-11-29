From: "Greg Scott" <GregScott@Infrasupport.com>
Subject: RE: ebtables on a stick
Date: Tue, 29 Nov 2011 04:05:18 -0600
Message-ID: <925A849792280C4E80C5461017A4B8A2A048BC@mail733.InfraSupportEtc.com>
References: <925A849792280C4E80C5461017A4B8A2A04879@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487A@mail733.InfraSupportEtc.com> <925A849792280C4E80C5461017A4B8A2A0487F@mail733.InfraSupportEtc.com> <20111128143901.GA589422@jupiter.n2.diac24.net> <925A849792280C4E80C5461017A4B8A2A0488A@mail733.InfraSupportEtc.com> <20111128153002.GB589422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Lamparter" <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.infrasupportetc.com ([216.160.2.132]:33834 "EHLO
	mail.infrasupport.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440Ab1K2KFT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 05:05:19 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We already had this discussion in July.
>
> "ip neigh add proxy" is independent of /proc/.../proxy_arp.

We did discuss this back in July but never finished.  I posted a bunch
of questions about "ip neigh add proxy" because I haven't seen much in
the way of documentation.  When nobody answered, I left it alone for a
while.  

I found a discussion starting here:
http://lkml.indiana.edu/hypermail/linux/kernel/0110.2/0523.html

where some of the kernel folks are suggesting "ip neigh add proxy" is
deprecated.  By now that discussion is 10 years old and it apparently is
still around.  But for how long?

Appendix B of this 2007 document, http://linux-ip.net/html/index.html,
by Martin Brown also says "ip neigh add proxy" is deprecated.  

So now, in addition to my paranoia about proxy ARP in general, I have
this fear I will build a bunch of scripting around "ip neigh add proxy"
only to find it's gone in a future kernel, leaving me in a world of hurt
again.  

So humor me and convince me that "ip neigh add" is not on the chopping
block so I can try it with a little bit of confidence.  

Thanks

- Greg
