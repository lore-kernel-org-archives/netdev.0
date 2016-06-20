From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Mon, 20 Jun 2016 12:41:23 -0500
Message-ID: <57682AC3.4040003@codeaurora.org>
References: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
 <20160619141757.GA4249@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
	agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20160619141757.GA4249@rob-hp-laptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
>> >+		dma-ranges = <0 0 0xffffffff>;
> I believe dma-ranges is supposed to be in the bus (parent) node.

Maybe I'm just going to be perpetually confused by dma-ranges, but how 
can I specify that the emac has a different DMA range from another SOC 
device, if dma-ranges is in the parent node?

The EMAC itself is capable of 64-bit DMA internally (I should have 
included a dma_set_mask call with DMA_BIT_MASK(64) in the driver). 
However, the platform typically limits this range.  On FSM9900 and 
QDF2432, it's 32 bits.  On the next server chip, it'll be the full 64 
bits.  I need some way to handle that.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
