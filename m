From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v8] net: emac: emac gigabit ethernet controller driver
Date: Thu, 25 Aug 2016 18:38:54 -0500
Message-ID: <57BF818E.5030302@codeaurora.org>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
 <db618958-a940-9ea2-ff52-e12c81894ad6@gmail.com>
 <57B4BD40.1070703@codeaurora.org>
 <e1bdbfa3-c74e-6f08-da36-632224f2bcd9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        sdharia@codeaurora.org, shankerd@codeaurora.org,
        vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
        robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
        mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
        davem@davemloft.net, LinoSanfilippo@gmx.de
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <e1bdbfa3-c74e-6f08-da36-632224f2bcd9@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
>>> >>Since you have a check on CONFIG_QCOM_EMAC in emac/Makefile, you could
>>> >>always recurse into that directory while building (use obj-y).
>> >
>> >Obviously, having "obj-$(CONFIG_QCOM_EMAC)" in both Makefiles is
>> >redundant, but wouldn't it make more sense to change
>> >"obj-$(CONFIG_QCOM_EMAC)" to "obj-y" in
>> >drivers/net/ethernet/qualcomm/emac/Makefile, so that I only recurse if
>> >necessary?

> Whichever makes the most sense, when there is a directory involved, my
> preference is to always recurse in that directory and selectively
> compile from there, since the Kconfig/Makefile options are all located
> within the same hierarchical level, just a preference.

It turns out that the way I changed it in v9 prevents the driver from 
being built as a module.  I changed the wrong Makefile.  I will have to 
post a v10.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
