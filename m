From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Mon, 25 Mar 2013 17:30:46 +0100
Message-ID: <20130325163046.GA29705@order.stressinduktion.org>
References: <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com> <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com> <20130324051325.GE17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com> <20130324052300.GA12968@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7D1E@nasanexd02f.na.qualcomm.com> <20130324172304.GB12968@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57213 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758694Ab3CYQas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:30:48 -0400
Content-Disposition: inline
In-Reply-To: <20130324172304.GB12968@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 06:23:04PM +0100, Hannes Frederic Sowa wrote:
> > 2. try to set hw->dmaw_block = atl1e_dma_req_128 
> 
> Sorry, we can still reproduce corrupted frames with this change.

In atl1e_main.c

    940         max_pay_load  = ((dev_ctrl_data >> DEVICE_CTRL_MAX_PAYLOAD_SHIFT)) &
    941                         DEVICE_CTRL_MAX_PAYLOAD_MASK;
    942 
    943         hw->dmaw_block = min_t(u32, max_pay_load, hw->dmaw_block);

the value dmaw_block always gets reset to 0 on my machine. I forced it
to use atl1e_dma_req_1024 as it seems intended. But no change either.

Thanks,

  Hannes
