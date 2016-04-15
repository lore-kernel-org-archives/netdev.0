From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 15 Apr 2016 10:44:48 -0500
Message-ID: <57110C70.9090007@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571012E6.6050303@codeaurora.org>
 <57102920.7000104@codeaurora.org>
 <CAL_JsqLJffKzvMZTSLf+OESufDjrcMBd27fP5yh1R61=irXxcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vikram Sethi <vikrams@codeaurora.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>,
	Christopher Covington <cov@codeaurora.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
To: Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAL_JsqLJffKzvMZTSLf+OESufDjrcMBd27fP5yh1R61=irXxcg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
>> >
>> >         dma-mask = <0 0xffffffff>;
>> >
>> >or
>> >
>> >         dma-mask = <0xffffffff 0xffffffff>;
> No. See dma-ranges.

How exactly should I use dma-ranges?  I can't find any other drivers 
that queries that property and uses the result to call dma_set_mask.  I 
thought the dma-ranges property is intended to specify address 
translation.  I don't need to translate any address, I just need to know 
a single number.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
