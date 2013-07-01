From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fixed enh_desc set always zero
Date: Mon, 01 Jul 2013 13:33:20 -0700 (PDT)
Message-ID: <20130701.133320.1836756068826550053.davem@davemloft.net>
References: <015801ce73d2$12332070$36996150$%an@samsung.com>
	<51CD884A.4030509@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, netdev@vger.kernel.org, kgene.kim@samsung.com,
	cpgs@samsung.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107Ab3GAUdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:33:21 -0400
In-Reply-To: <51CD884A.4030509@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 28 Jun 2013 14:57:46 +0200

> On 6/28/2013 9:35 AM, Byungho An wrote:
>> 
>> This patch fixed that enh_desc value is always zero.
>> Due to calling order of stmmac_selec_desc_mode(), enh_desc value is always zero.
>> Even though mac is set to use enhanced dma descriptor, if enh_desc is zero,
>> functions related dma descriptor are not working correctly.
>> Signed-off-by: Byungho An <bh74.an@samsung.com>
> 
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
