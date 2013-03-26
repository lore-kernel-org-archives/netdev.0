From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/8 (v2)] stmmac: update to March_2013 (ext
 desc, PTP, SGMII)
Date: Tue, 26 Mar 2013 12:53:01 -0400 (EDT)
Message-ID: <20130326.125301.83068913322084821.davem@davemloft.net>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rayagond@vayavyalabs.com,
	richardcochran@gmail.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270Ab3CZQxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:53:03 -0400
In-Reply-To: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 26 Mar 2013 15:43:04 +0100

> These patches enhance the driver adding the PTP support and the initial code
> for RGMII/SGMII/TBI/RTBI modes.
> Also this patches review the driver removing some Koption for selecting between
> chain and ring modes. REally useful to validate the driver also at build time.
> Before adding PTP, the extended descriptor support has been added because it
> is mandatory to save HW timestamp in new dedicated descriptors. Also in this
> case no Koption added.
> 
> Concerning the PTP, I have hacked/reviewed and tested many
> part of these patches also verifying the back compatibility on
> several HW and chips.
> 
> Concerning the SGMII/RGMII we have already discussed about the support
> in the net.dev Mailing list with Byungho where these patchs were partially
> analysed.
> So I have only ported them against the latest net-next (and on
> top of PTP). I have added some missing things: e.g. some parts of the
> ethtool for ANE. As we clarified with Byungho, we will add further
> enhancements on top of these patches if needed.
> 
> I have also built all against ARM/SH/X68 platforms and no issues on
> ST-Boxes.
> 
> Thx goes to Rayagond that wrote and tested the PTP and to Byungho for SGMII.
> 
> V2: This Version 2 has the fixes discussed in the ML, for example:
>     o completely remove the Koption... all the decisions are made at probe time
>     o review the PTP patches and better organize them just in two patches
>     o added all the fixes provided by Richard on PTP and CLK driver.

This looks a lot better, series applied, thanks.
