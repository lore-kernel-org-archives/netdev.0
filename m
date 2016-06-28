From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 0/3] stmmac: rework and enhance the PCS
 support
Date: Tue, 28 Jun 2016 08:54:46 -0400 (EDT)
Message-ID: <20160628.085446.2304542819607384051.davem@davemloft.net>
References: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404AbcF1MzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 08:55:17 -0400
In-Reply-To: <1466774186-2320-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Fri, 24 Jun 2016 15:16:23 +0200

> The 3.xx and 4.xx synopsys gmacs have a very similar
> PCS embedded module and they share almost the same registers;
> for example:
>   AN_Control, AN_Status, AN_Advertisement, AN_Link_Partner_Ability,
>   AN_Expansion, TBI_Extended_Status.
> 
> Just the RGMII/SMII Control/Status register differs.
> 
> So these patches aim to reorganize and enhance the PCS support;
> to do that, some small inline functions have been provided and
> also some rework to the PCS ISR part has been done.
> 
> In the end, the SGMII for MAC2MAC connection has been introduced.
> 
> All patches have been built on top of net-next git and, as for
> the previous version, not fully tested.

Series applied, thanks.
