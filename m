From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Thu, 23 Mar 2017 16:56:13 -0700 (PDT)
Message-ID: <20170323.165613.802100008000968298.davem@davemloft.net>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
        <20170322.114439.679826829857326050.davem@davemloft.net>
        <20170322215733.GH20094@minitux>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        k.eugene.e@gmail.com, kvalo@codeaurora.org, andy.gross@linaro.org,
        david.brown@linaro.org, arnd@arndb.de,
        linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-soc@vger.kernel.org
To: bjorn.andersson@linaro.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170322215733.GH20094@minitux>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Wed, 22 Mar 2017 14:57:33 -0700

> On Wed 22 Mar 11:44 PDT 2017, David Miller wrote:
> 
>> From: Bjorn Andersson <bjorn.andersson@linaro.org>
>> Date: Mon, 20 Mar 2017 16:35:42 -0700
>> 
>> What is the status of the Kconfig dependency fix and how will I be
>> getting it?
>> 
> 
> There are two Kconfig dependencies in play here, the first is
> c3104aae5d8c ("remoteproc: qcom: fix QCOM_SMD dependencies"), this was
> picked up by Linus yesterday and will as such be in v4.10-rc4.
> 
> The other dependency, is the one Marcel wants you to pick up here is
> https://patchwork.kernel.org/patch/9635385/. It's on LKML, but if you
> want I can resend it with you as direct recipient, with Marcel's ack.
> 
> Likely Arnd would like this fix to be sent upstream for v4.11 already.
> 
>> Second, should I merge all three of these patches to net-next or just
>> this one?
>> 
> 
> I would like all three to be merged in this cycle and in addition I have
> a couple of patches coming up that will cause some minor conflicts with
> patch 2 - so I would prefer if patch 2 was available in a tag I can
> merge into my tree.

I should have all the dependencies in net-next now, but when I apply
this series I get undefined symbols:

[davem@localhost net-next]$ time make -s -j8
Kernel: arch/x86/boot/bzImage is ready  (#578)
ERROR: "qcom_rpm_smd_write" [drivers/regulator/qcom_smd-regulator.ko] undefined!
ERROR: "qcom_wcnss_open_channel" [drivers/net/wireless/ath/wcn36xx/wcn36xx.ko] undefined!
ERROR: "qcom_rpm_smd_write" [drivers/clk/qcom/clk-smd-rpm.ko] undefined!
ERROR: "qcom_wcnss_open_channel" [drivers/bluetooth/btqcomsmd.ko] undefined!
scripts/Makefile.modpost:91: recipe for target '__modpost' failed

Please fix this up.
