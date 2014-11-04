From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix sparse warnings
Date: Tue, 04 Nov 2014 16:59:58 -0500 (EST)
Message-ID: <20141104.165958.657451417783601838.davem@davemloft.net>
References: <1415035734-24163-1-git-send-email-andriy.shevchenko@linux.intel.com>
	<54590045.3050305@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andriy.shevchenko@linux.intel.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59747 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaKDWAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 17:00:00 -0500
In-Reply-To: <54590045.3050305@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 4 Nov 2014 17:35:17 +0100

> On 11/3/2014 6:28 PM, Andy Shevchenko wrote:
>> This patch fixes the following sparse warnings.
>>
>> drivers/net/ethernet/stmicro/stmmac/enh_desc.c:381:30: warning: symbol
>> 'enh_desc_ops' was not declared. Should it be static?
>> drivers/net/ethernet/stmicro/stmmac/norm_desc.c:253:30: warning:
>> symbol 'ndesc_ops' was not declared. Should it be static?
>> drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c:141:33: warning:
>> symbol 'stmmac_ptp' was not declared. Should it be static?
>>
>> There is no functional change.
> 
> Hello Andy
> 
> I have never seen this kind of warnings.

Are you running the 'sparse' checker with all options enabled?
This is one of the most fundamental warnings it spits out.

> I prefer to not include the
> stmmac.h in enh_desc.c and norm_desc.c but eventually to move the
> following from stmmac.h to common.h:
>   extern const struct stmmac_desc_ops enh_desc_ops;
>   extern const struct stmmac_desc_ops ndesc_ops;
> what do you think?

You two sort this out and submit a new patch, thanks.
