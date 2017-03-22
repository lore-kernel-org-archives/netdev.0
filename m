From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd
 to rpmsg
Date: Wed, 22 Mar 2017 11:44:39 -0700 (PDT)
Message-ID: <20170322.114439.679826829857326050.davem@davemloft.net>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
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
In-Reply-To: <20170320233544.1656-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Mon, 20 Mar 2017 16:35:42 -0700

> By moving these client drivers to use RPMSG instead of the direct SMD
> API we can reuse them ontop of the newly added GLINK wire-protocol
> support found in the 820 and 835 Qualcomm platforms.
> 
> As the new (RPMSG-based) and old SMD implementations are mutually
> exclusive we have to change all client drivers in one commit, to make
> sure we have a working system before and after this transition.
> 
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
> 
> Based on v4.11-rc3 with Arnd's Kconfig dependency fixes for BT_QCOMSMD
> (https://lkml.org/lkml/2017/3/20/1038).

Just some questions since I'm supposed to merge this into my net-next
tree.

What is the status of the Kconfig dependency fix and how will I be
getting it?

Second, should I merge all three of these patches to net-next or just
this one?

Thanks.
