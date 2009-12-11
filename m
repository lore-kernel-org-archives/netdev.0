From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [RFC] gianfar: Fix stats support
Date: Fri, 11 Dec 2009 10:20:35 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08B37@zin33exm22.fsl.freescale.net>
References: <1260423764-21210-1-git-send-email-Sandeep.Kumar@freescale.com> <20091210151137.GB17851@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:64860 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762300AbZLKEui convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 23:50:38 -0500
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id nBB4ojcT018009
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 21:50:45 -0700 (MST)
Received: from zin33exm22.fsl.freescale.net (zin33exm22.ap.freescale.net [10.232.192.20])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id nBB4su5n003717
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:54:57 -0600 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <20091210151137.GB17851@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c index 
>> 73ccb07..7e6f4e4 100644
>> --- a/drivers/net/gianfar.c
>> +++ b/drivers/net/gianfar.c
>> @@ -143,6 +143,7 @@ void gfar_start(struct net_device *dev);  static 
>> void gfar_clear_exact_match(struct net_device *dev);  static void 
>> gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);  
>> static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int 
>> cmd);
>> +static struct net_device_stats *gfar_get_stats(struct net_device 
>> +*dev);
>
>Just a cosmetic nitpick: please avoid adding new forward declarations.
>
>In this case I think you could easily move this function 
>before gfar_netdev_ops.
>

OK. Will send out a new patch.

--

Thanks
Sandeep
