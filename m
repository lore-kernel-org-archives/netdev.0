From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH v4 1/4] stmmac: create of compatible mdio bus for stmacc
 driver
Date: Wed, 9 Dec 2015 10:47:29 +0800
Message-ID: <56679641.7060101@electromag.com.au>
References: <201512091033.svvb9HL7%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	vbridger@opensource.altera.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy1.45ru.net.au ([203.30.46.145]:35736 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751187AbbLICrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 21:47:48 -0500
In-Reply-To: <201512091033.svvb9HL7%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/12/2015 10:15 AM, kbuild test robot wrote:

>
> url:    https://github.com/0day-ci/linux/commits/Phil-Reid/stmmac-create-of-compatible-mdio-bus-for-stmacc-driver/20151209-094242
> config: x86_64-randconfig-b0-12090825 (attached as .config)
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>     drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c: In function 'stmmac_mdio_register':
>>> drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c:226:17: error: 'struct stmmac_mdio_bus_data' has no member named 'reset_gpio'
>         mdio_bus_data->reset_gpio = -1;
>                      ^

G'day Arnd,

I got the above error from kbuild test robot. When changing to if (IS_ENABLED(CONFIG_OF)).
This was existing code that I moved into this conditional.
reset_gpio member only exists when CONFIG_OF is defined.
So it looks like I need to move that code back to the #if.
unless you have an alternate suggestion.


--
Regards
Phil Reid
