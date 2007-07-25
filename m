From: Joel Schopp <jschopp@austin.ibm.com>
Subject: Re: [Cbe-oss-dev] [PATCH 0/10] ps3: fixes for ps3_gelic driver
Date: Wed, 25 Jul 2007 11:11:49 -0500
Message-ID: <46A77645.8040902@austin.ibm.com>
References: <20070720162345.6775.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org, Linas Vepstas <linas@austin.ibm.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42385 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761940AbXGYQL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 12:11:57 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6PGBrJT030277
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 12:11:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6PGBrfM498964
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 12:11:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6PGBqdW032450
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 12:11:52 -0400
In-Reply-To: <20070720162345.6775.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since gelic and spidernet are 95% identical it would be a good idea to cc the 
spidernet maintainer Linas on these patches (ccd on this reply).

Masakazu Mokuno wrote:
> This patchset are fixes and updates incorporating the comments from Jeff
> Garzik and Stephen Hemminger.
> Please accept the following patches for the ps3_gelic driver.  Thanks.
> 
>  [1] ps3: fix wrong calculation of rx descriptor address
>  [2] ps3: some minor cleanups
>  [3] ps3: tx descriptor handling cleanup
>  [4] ps3: removed defines no longer used
>  [5] ps3: removed conditional ethtool support
>  [6] ps3: use net_device_stats of net_device structure
>  [7] ps3: use ethX as the name of irq
>  [8] ps3: removed calling netif_poll_enable() in open()
>  [9] ps3: fix rare issue that reenabling rx DMA fails
> [10] ps3: reduce allocation size of rx skb buffers
> 
> 
> --
> Masakazu MOKUNO
> 
> _______________________________________________
> cbe-oss-dev mailing list
> cbe-oss-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/cbe-oss-dev


