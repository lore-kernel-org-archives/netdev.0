From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: Switch tag HW extraction/insertion
Date: Fri, 31 Jul 2015 15:24:09 -0700 (PDT)
Message-ID: <20150731.152409.2044548175661477590.davem@davemloft.net>
References: <20150730.141935.723435302404122784.davem@davemloft.net>
	<20150730.155124.2216613161860898066.davem@davemloft.net>
	<55BAD4BD.20405@alphacore.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: florian@alphacore.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55BAD4BD.20405@alphacore.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <florian@alphacore.org>
Date: Thu, 30 Jul 2015 18:51:57 -0700

> On 30/07/15 15:51, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Thu, 30 Jul 2015 14:19:35 -0700 (PDT)
>> 
>>> This looks fine, series applied, thanks.
>> 
>> I think your control block is too large, you'll need to rework this
>> somehow.
> 
> So napi_gro_cb really is 48 bytes on 64-bits architectures (had not
> realized it was so big).
> 
> What would you recommend to do here considering that this driver is
> currently used on 32-bits platforms, but I see no reason why someone
> would no want to use this feature on a 64-bit platform, yet we are
> competing with napi_gro_cb, and adding a new skbuff member is pretty
> much a no-no? Would it be acceptable to have a new member which is ifdef
> CONFIG_NET_DSA_TAG_BRCM?
> 
> FWIW, this does provide a small 2-3% throughput increase for RX.

You really need to find a way to make it fit in it's current size
on 64-bit.
