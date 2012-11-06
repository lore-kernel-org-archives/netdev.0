From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/7] ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for davinci_mdio
 module
Date: Tue, 6 Nov 2012 16:54:53 +0530
Message-ID: <5098F385.6020009@ti.com>
References: <1352189545-26303-1-git-send-email-mugunthanvnm@ti.com> <1352189545-26303-4-git-send-email-mugunthanvnm@ti.com> <B5906170F1614E41A8A28DE3B8D121433EC049CC@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Paul Walmsley <paul@pwsan.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:42451 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab2KFL0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 06:26:14 -0500
In-Reply-To: <B5906170F1614E41A8A28DE3B8D121433EC049CC@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/6/2012 3:39 PM, Bedia, Vaibhav wrote:
> On Tue, Nov 06, 2012 at 13:42:21, N, Mugunthan V wrote:
> [...]
>> +struct omap_hwmod_addr_space am33xx_mdio_addr_space[] = {
>> +	{
>> +		.pa_start	= 0x4A101000,
>> +		.pa_end		= 0x4A101000 + SZ_256 - 1,
>> +		.flags		= ADDR_MAP_ON_INIT,
> Based on the recent discussions and looking the hwmod code,
> I guess ADDR_MAP_ON_INIT does not make sense here. Since you
> are just creating a parent-child relationship here, maybe no
> flag is needed?
>
>> +	},
>> +	{ }
>> +};
>> +
>> +struct omap_hwmod_ocp_if am33xx_cpgmac0__mdio = {
>> +	.master		= &am33xx_cpgmac0_hwmod,
>> +	.slave		= &am33xx_mdio_hwmod,
>> +	.addr		= am33xx_mdio_addr_space,
>> +	.user		= OCP_USER_MPU,
> Is this flag necessary? Shouldn't you just skip the
> user field since there's nothing for the hwmod code
> to do here?
>
>
Will remove the unnecessary flags and submit the patch.

Regards
Mugunthan V N
