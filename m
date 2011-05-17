From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 10:15:07 +0200
Message-ID: <BANLkTikQnhwL8knodrUT940onp8DjGXVGw@mail.gmail.com>
References: <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com>
 <20110516093822.GA2779@gondor.apana.org.au> <20110516094821.GA9427@redhat.com>
 <20110516104309.GA3534@gondor.apana.org.au> <20110516112133.GA11274@redhat.com>
 <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
 <20110516224658.GA11157@gondor.apana.org.au> <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	=?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:43025 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab1EQIP2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 04:15:28 -0400
Received: by qyg14 with SMTP id 14so128299qyg.19
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 01:15:28 -0700 (PDT)
In-Reply-To: <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 17 maja 2011 10:08 u=BFytkownik Micha=B3 Miros=B3aw <mirqus@gmai=
l.com> napisa=B3:
> In the tun/tap case, by using TUNSETOFFLOAD userspace advertises that
> it is willing to receive unchecksummed/TSOed packets from kernel (it
> should use TUN_VNET_HDR for this to work correctly unless it doesn't
> forward the packets). After the conversion, those offloads can be
> disabled by using ethtool even if userspace does support them.
> Previously you were able to push offloaded packets to apllications no=
t
> prepared for them.

And there is a bug in the logic implementing this. I'll send a fix in a=
 minute.

Best Regards,
Micha=B3 Miros=B3aw
