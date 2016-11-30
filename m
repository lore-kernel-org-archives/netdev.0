From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts
 HW_TS_PUSH
Date: Wed, 30 Nov 2016 14:15:04 -0600
Message-ID: <86be8bbd-39c6-6173-9e84-b8afe92e5474@ti.com>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-4-grygorii.strashko@ti.com>
 <1480504100.9183.72.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
        <devicetree@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>
To: =?UTF-8?Q?Jan_L=c3=bcbbe?= <jlu@pengutronix.de>,
        Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480504100.9183.72.camel@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/30/2016 05:08 AM, Jan Lübbe wrote:
> On Mo, 2016-11-28 at 17:04 -0600, Grygorii Strashko wrote:
>> This patch adds support of the CPTS HW_TS_PUSH events which are generated
>> by external low frequency time stamp channels on TI's OMAP CPSW and
>> Keystone 2 platforms. It supports up to 8 external time stamp channels for
>> HW_TS_PUSH input pins (the number of supported channel is different for
>> different SoCs and CPTS versions, check corresponding Data maual before
>> enabling it). Therefore, new DT property "cpts-ext-ts-inputs" is introduced
>> for specifying number of available external timestamp channels.
> 
> If this only depends on SoC and CTPS, it should be possible to derive
> the correct value from the compatible value and possibly a CPTS version
> register? If the existing compatible strings are not specific enough,
> possible a new one should be added.
> 

In general, I can try to add and use new compat strings
"ti,netcp-k2hk"
"ti,netcp-k2l"
"ti,netcp-k2e"
"ti,netcp-k2g" 
for determining CPTS capabilities.

CPTS version is not the choice due to very poor documentation
which do not allow identify relations between CPTS ver and supported
features :(

Murali, what do you think?


-- 
regards,
-grygorii
