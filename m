From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd to
 rpmsg
Date: Tue, 21 Mar 2017 09:20:01 +0100
Message-ID: <3DCEF38C-F8FC-4941-936F-921247E13B78@holtmann.org>
References: <20170320233544.1656-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>,
        "open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, wcn36xx@lists.infradead.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170320233544.1656-1-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

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
> 
> drivers/bluetooth/Kconfig                  |  2 +-
> drivers/bluetooth/btqcomsmd.c              | 32 +++++++++----------
> drivers/net/wireless/ath/wcn36xx/Kconfig   |  2 +-
> drivers/net/wireless/ath/wcn36xx/main.c    |  6 ++--
> drivers/net/wireless/ath/wcn36xx/smd.c     | 10 +++---
> drivers/net/wireless/ath/wcn36xx/smd.h     |  6 ++--
> drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  2 +-
> drivers/soc/qcom/Kconfig                   |  4 +--
> drivers/soc/qcom/smd-rpm.c                 | 43 +++++++++++++------------
> drivers/soc/qcom/wcnss_ctrl.c              | 50 +++++++++++++++++-------------
> include/linux/soc/qcom/wcnss_ctrl.h        | 11 ++++---
> net/qrtr/Kconfig                           |  2 +-
> net/qrtr/smd.c                             | 42 ++++++++++++-------------
> 13 files changed, 108 insertions(+), 104 deletions(-)

I think that it is best if Dave takes these directly then and I pull them back down later into our trees. Including the Kconfig fix that I will ACK as well.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
