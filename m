From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Thu, 4 Aug 2016 13:18:55 -0500
Message-ID: <57A3870F.8020203@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
	agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com,
	LinoSanfilippo@gmx.de
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20160804175541.GA2832@rob-hp-laptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
>> >+- phy-version : the version of the integrated emac phy, either 1 or 2.
> Sounds like 2 different h/w. The compatible property should distinguish
> this.

Well, the MAC parts of the EMAC is the same.  I could do 
qcom,fsm9900-emac for v1 and qcom,qdf2432-emac for v2.  I can't really 
think of a reason why that wouldn't work.

For ACPI, we can assume that QCOM8070 is a v2 PHY.  If Qualcomm creates 
another server chip with a v1 PHY, it would need a new ACPI HID.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
