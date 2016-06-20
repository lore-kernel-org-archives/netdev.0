From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Mon, 20 Jun 2016 13:49:10 -0500
Message-ID: <57683AA6.7020302@codeaurora.org>
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
>> >+		interrupt-parent = <&emac0>;
>> >+		#interrupt-cells = <1>;
>> >+		interrupts = <0 1>;
>> >+		interrupt-map-mask = <0xffffffff>;
>> >+		interrupt-map = <0 &intc 0 76 0
>> >+				 1 &intc 0 80 0>;
> Why? This looks unnecessary.

It may have made sense with an earlier version of the driver that had 
more complex interrupts.  I'll fix it in v6.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
