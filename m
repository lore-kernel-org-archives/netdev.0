From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Tue, 28 Mar 2017 17:58:29 -0700 (PDT)
Message-ID: <20170328.175829.1477125931644243041.davem@davemloft.net>
References: <20170327225836.GL20094@minitux>
        <20170327.160400.1285256003980361221.davem@davemloft.net>
        <20170328054922.GH70446@Bjorns-MacBook-Pro-2.local>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170328054922.GH70446@Bjorns-MacBook-Pro-2.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Mon, 27 Mar 2017 22:49:22 -0700

> On Mon 27 Mar 16:04 PDT 2017, David Miller wrote:
> 
>> From: Bjorn Andersson <bjorn.andersson@linaro.org>
>> Date: Mon, 27 Mar 2017 15:58:37 -0700
>> 
>> > I'm sorry, but I can't figure out how to reproduce this.
>> 
>> All of my builds are "make allmodconfig" so it should be easy to reproduce.
> 
> Thanks, turns out that while it was possible to select CONFIG_SMD_RPM
> and CONFIG_QCOM_WCNSS_CTRL drivers/soc/Makefile does not traverse into
> qcom/ unless CONFIG_ARCH_QCOM was set.
> 
> So I just sent out version 2 of the three patches, where I add an
> explicit dependency on ARCH_QCOM for those two options.

Looks great, all three applied.
