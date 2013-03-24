From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sun, 24 Mar 2013 18:24:00 +0100
Message-ID: <20130324172400.GC12968@order.stressinduktion.org>
References: <20130324014125.GB17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7C79@nasanexd02f.na.qualcomm.com> <20130324034037.GC17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CA8@nasanexd02f.na.qualcomm.com> <20130324043738.GD17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CCD@nasanexd02f.na.qualcomm.com> <20130324051325.GE17948@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7CFC@nasanexd02f.na.qualcomm.com> <20130324052300.GA12968@order.stressinduktion.org> <157393863283F442885425D2C4542856489E7D3C@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55181 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab3CXRYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 13:24:01 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C4542856489E7D3C@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 24, 2013 at 06:12:08AM +0000, Huang, Xiong wrote:
> And try to use following code to replace atl1c_configure_dma
> 
> static inline void atl1e_configure_dma(struct atl1e_adapter *adapter)
> {
> 	struct atl1e_hw *hw = &adapter->hw;
> 	u32 dma_ctrl_data;
> 
> 	dma_ctrl_data = DMA_CTRL_RXCMB_EN | 0x400000;
> 	dma_ctrl_data |= (((u32)hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
> 		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT;
> 	dma_ctrl_data |= (((u32)hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN_MASK)
> 		<< DMA_CTRL_DMAW_BURST_LEN_SHIFT;
> 	dma_ctrl_data |= DMA_CTRL_DMAR_REQ_PRI | DMA_CTRL_DMAR_OUT_ORDER;
> 	dma_ctrl_data |= (((u32)hw->dmar_dly_cnt) & DMA_CTRL_DMAR_DLY_CNT_MASK)
> 		<< DMA_CTRL_DMAR_DLY_CNT_SHIFT;
> 	dma_ctrl_data |= (((u32)hw->dmaw_dly_cnt) & DMA_CTRL_DMAW_DLY_CNT_MASK)
> 		<< DMA_CTRL_DMAW_DLY_CNT_SHIFT;
> 
> 	AT_WRITE_REG(hw, REG_DMA_CTRL, dma_ctrl_data);
> 	return;
> }

Also no change. Corrupted frames still occur.

Thanks,

  Hannes
