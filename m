From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 2/2] stmmac: Fix kernel crashes for jumbo
 frames
Date: Wed, 15 Jan 2014 14:57:25 -0800 (PST)
Message-ID: <20140115.145725.801343084524328515.davem@davemloft.net>
References: <1389719859-29071-3-git-send-email-vbridgers2013@gmail.com>
	<1389729216.2025.197.camel@bwh-desktop.uk.level5networks.com>
	<CAOwfj2Ne1oRU1z6BaH4g2_EJJFtJOWbgs2oMzSq5nNpz9G6LsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, peppe.cavallaro@st.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	dinguyen@altera.com, rayagond@vayavyalabs.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41520 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbaAOW50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 17:57:26 -0500
In-Reply-To: <CAOwfj2Ne1oRU1z6BaH4g2_EJJFtJOWbgs2oMzSq5nNpz9G6LsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Tue, 14 Jan 2014 14:44:35 -0600

> On Tue, Jan 14, 2014 at 1:53 PM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
>> On Tue, 2014-01-14 at 11:17 -0600, Vince Bridgers wrote:
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> @@ -51,6 +51,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
>>>       plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
>>>                                          sizeof(struct stmmac_mdio_bus_data),
>>>                                          GFP_KERNEL);
>>> +     /* Set the maxmtu to a default of 1500 in case the
>>> +      * parameter is not present in the device tree
>>> +      */
>>> +     plat->maxmtu = JUMBO_LEN;
>>
>> The comment disagrees with the definition of JUMBO_LEN.
> 
> ok, I'll address the comment inconsistency.

Therefore I'm expecting to see a v4 of this series at some point,
thanks.
