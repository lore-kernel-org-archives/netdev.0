From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Thu, 28 Mar 2013 02:16:02 +0100
Message-ID: <20130328011602.GB2176@order.stressinduktion.org>
References: <20130326042700.GC29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E821B@nasanexd02f.na.qualcomm.com> <20130326044025.GD29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E8232@nasanexd02f.na.qualcomm.com> <20130327220248.GD23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FDF82@nasanexd02f.na.qualcomm.com> <20130327223433.GE23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FFFCE@nasanexd02f.na.qualcomm.com> <20130328004024.GA2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FE9@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35309 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab3C1BQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 21:16:03 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F200FE9@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 01:01:05AM +0000, Huang, Xiong wrote:
> Please try to use following define in atl1e_hw.h
>  
> #define     GPHY_CTRL_DEFAULT (\
> 		GPHY_CTRL_SEL_ANA_RST	|\
> 		GPHY_CTRL_HIB_PULSE	|\
> 		GPHY_CTRL_HIB_EN)

No change either.

We will try to go with RXQ_CTRL_PBA_ALIGN_256 in REG_RXQ_CTRL next. Just have
to check the ring resources are initialized correctly.

Thanks,

  Hannes
