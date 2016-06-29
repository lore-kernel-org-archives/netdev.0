From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 10:46:23 -0500
Message-ID: <5773ED4F.4050401@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <5679359.84lXZytcOR@wuerfel> <5773E503.3070404@codeaurora.org>
 <3914163.aNiIdzedWT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <3914163.aNiIdzedWT@wuerfel>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> Usually drivers try 64-bit mask and 32-bit masks, and the 32 bit
> mask is practically guaranteed to succeed.

Sure, but in theory, my for-loop is correct, right?  Wouldn't there be 
some value in setting a 36-bit or 40-bit DMA mask if it works?  We have 
a platform where memory starts at a 40-bit address, so some devices have 
a 44-bit address bus.  If a 64-bit mask doesn't work, then a 32-bit mask 
certainly wont.

> Platforms will also allow allow the driver to set a mask that
> is larger than what the bus supports, as long as all RAM is
> reachable by the bus.

And that check (like all others) is made in the dma_set_mask call?

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
