From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd to
 rpmsg
Date: Wed, 22 Mar 2017 20:23:15 +0100
Message-ID: <21FCFC89-07EE-49EE-81C2-A138DD4C5F99@holtmann.org>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
 <20170322.114439.679826829857326050.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>, arnd@arndb.de,
        linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-msm@vger.kernel.org,
        linux-soc@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170322.114439.679826829857326050.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

>> By moving these client drivers to use RPMSG instead of the direct SMD
>> API we can reuse them ontop of the newly added GLINK wire-protocol
>> support found in the 820 and 835 Qualcomm platforms.
>> 
>> As the new (RPMSG-based) and old SMD implementations are mutually
>> exclusive we have to change all client drivers in one commit, to make
>> sure we have a working system before and after this transition.
>> 
>> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
>> ---
>> 
>> Based on v4.11-rc3 with Arnd's Kconfig dependency fixes for BT_QCOMSMD
>> (https://lkml.org/lkml/2017/3/20/1038).
> 
> Just some questions since I'm supposed to merge this into my net-next
> tree.
> 
> What is the status of the Kconfig dependency fix and how will I be
> getting it?

I acked that one separately and added you:

[PATCH v2] Bluetooth: btqcomsmd: fix compile-test dependency

> Second, should I merge all three of these patches to net-next or just
> this one?

I think you have to take all 3 patches. Otherwise it will break.

Regards

Marcel
