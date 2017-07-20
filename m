From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: Push the request_irq function to
 the end of probe
Date: Thu, 20 Jul 2017 17:44:51 -0500
Message-ID: <0a5cdde6-5898-8f8c-5c56-d47fa9513958@ti.com>
References: <1500550192-6550-1-git-send-email-j-keerthy@ti.com>
 <5259f0e7-cc5d-35c9-8f09-94cf7b40f653@ti.com>
 <20170720.152831.802536956243282259.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <j-keerthy@ti.com>, <linux-omap@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <johan@kernel.org>, <ivan.khoronzhuk@linaro.org>,
        <t-kristo@ti.com>, <nsekhar@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170720.152831.802536956243282259.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/20/2017 05:28 PM, David Miller wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> Date: Thu, 20 Jul 2017 11:08:09 -0500
> 
>> In general patch looks good to me, but it's really unexpected to
>> receive IRQs while CPSW is probing ;(
> 
> This is a poor expectation.
> 
> Boot loaders and other entities can leave the device in any state
> whatsoever.
> 
> Furthermore, enabling an IRQ whose handler cannot properly execute
> without crashing is wrong fundamentally.  All data structures and
> state must be set up properly before the IRQ is requested.
> 
> Therefore this patch is correct and I will apply it.
> 

Thanks. Agree (it just has never triggered before, so I meant - unexpected
 from current driver code point of view ;().
And I'm just worry that it might not be enough :(, especially for am335x.

-- 
regards,
-grygorii
