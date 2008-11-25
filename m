From: SEBASTIEN LEGER <sebastienleger@yahoo.fr>
Subject: Re : [PATCH] Naming interrupt vectors/niu
Date: Tue, 25 Nov 2008 17:19:53 +0000 (GMT)
Message-ID: <625027.33655.qm@web28104.mail.ukl.yahoo.com>
References: <18732.7560.67492.918339@robur.slu.se> <Pine.LNX.4.64.0811251652240.27162@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jesper Dangaard Brouer <hawk@diku.dk>,
	Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web28104.mail.ukl.yahoo.com ([217.146.182.124]:31122 "HELO
	web28104.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752519AbYKYSCb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 13:02:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

on multiqueue hardware, isn't RSS meant to bind packets from the same f=
low on a specific cpu?

So, does it make sense to control RX smp affinity from /proc/irq/*/smp_=
affinity on multiqueue adapters with RSS support?

thanks,

Sebastien

________________________________
De : Jesper Dangaard Brouer <hawk@diku.dk>
=C0 : Robert Olsson <robert@robur.slu.se>
Cc : David Miller <davem@davemloft.net>; netdev@vger.kernel.org; Robert=
=2EOlsson@data.slu.se
Envoy=E9 le : Mardi, 25 Novembre 2008, 16h58mn 06s
Objet : Re: [PATCH] Naming interrupt vectors/niu


On Tue, 25 Nov 2008, Robert Olsson wrote:

> A patch to put names on the niu interrupt vectors according the synta=
x below.
> This is needed to assign correct affinity.
>
> > So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> > have names like:
> >
> >     eth0-rx-0
> >     eth0-rx-1
> >     eth0-tx-0
> >     eth0-tx-1
>
>
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Tested-by: Jesper Dangaard Brouer <jdb@comx.dk>


I have tested the patch and it also works on the Quad 1G SUN NIC.
I really like the idea behind the patch, as it makes it a lot easier to=
=20
get the smp affinity right...

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



     =20
