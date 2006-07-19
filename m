From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 17:39:56 -0700 (PDT)
Message-ID: <20060718.173956.90822631.davem@davemloft.net>
References: <20060718081625.GA13830@2ka.mipt.ru>
	<20060718230121.GA31474@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1193
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932431AbWGSAjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 20:39:33 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060718230121.GA31474@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 19 Jul 2006 03:01:21 +0400

> The only improvement in this area suggested in VJ's slides is a
> lock-free producer-consumer ring. It is missing in your patch and I
> could guess it is not big loss, it is unlikely to improve something
> significantly until the lock is heavily contended, which never
> happens without massive network-level parallelism for a single
> bucket.

And the gains from this ring can be obtained by stateless hardware
classification pointing to unique MSI-X PCI interrupt vectors that get
targetted to specific unique cpus.  It is true zero cost in that case.

I guess my excitement about VJ channels, from a practical viewpoint,
begin to wane even further.  How depressing :)

Devices can move flow work to individual cpus via intellegent
interrupt targeting, and OS should just get out of the way and
continue doing what it does today.  This idea is actually very old,
and PCI MSI-X interrupts just make it practical for commodity devices.

At least, there is less code to write. :-)))
