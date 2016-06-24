From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Maxim/driver: Add driver for maxim ds26522
Date: Fri, 24 Jun 2016 15:46:08 -0400 (EDT)
Message-ID: <20160624.154608.48260039018744249.davem@davemloft.net>
References: <1466644185-6081-1-git-send-email-qiang.zhao@nxp.com>
	<20160623.105915.1184538161171070695.davem@davemloft.net>
	<AM3PR04MB11854F945F63BFF95C74AE94912E0@AM3PR04MB1185.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oss@buserror.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xiaobo.xie@nxp.com
To: qiang.zhao@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbcFXTqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 15:46:14 -0400
In-Reply-To: <AM3PR04MB11854F945F63BFF95C74AE94912E0@AM3PR04MB1185.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Qiang Zhao <qiang.zhao@nxp.com>
Date: Fri, 24 Jun 2016 02:00:33 +0000

> On Thu, 2016-06-23 at 10:59PM, David Miller wrote:
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Thursday, June 23, 2016 10:59 PM
>> To: Qiang Zhao <qiang.zhao@nxp.com>
>> Cc: oss@buserror.net; linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
>> Xiaobo Xie <xiaobo.xie@nxp.com>
>> Subject: Re: [PATCH] Maxim/driver: Add driver for maxim ds26522
>> 
>> From: Zhao Qiang <qiang.zhao@nxp.com>
>> Date: Thu, 23 Jun 2016 09:09:45 +0800
>> 
>> > +MODULE_DESCRIPTION(DRV_DESC);
>> 
>> There is no definition of DRV_DESC, so this makes it look like you didn't even
>> compile this driver.
> 
> I really, really compiled this driver.
> Thank you for your review and comments. I will modify it the next version.
> 
> [zhaoqiang@titan:~/upstream/linux]$ll drivers/net/wan/slic_ds26522.o
> -rw-r--r-- 1 zhaoqiang klocwork 153288 Jun 22 15:48 drivers/net/wan/slic_ds26522.o
> [zhaoqiang@titan:~/upstream/linux]$date

Obviously with the driver not configured as a module, and thus explicitly
not testing the failing statement at all.
