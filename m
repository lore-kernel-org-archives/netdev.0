From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v4 2/4] wcn36xx: Transition driver to SMD client
Date: Wed, 07 Sep 2016 14:35:17 +0300
Message-ID: <87zinkvt6y.fsf@kamboji.qca.qualcomm.com>
References: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
        <1473200312-22438-2-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, Andy Gross <andy.gross@linaro.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473200312-22438-2-git-send-email-bjorn.andersson@linaro.org>
        (Bjorn Andersson's message of "Tue, 6 Sep 2016 15:18:30 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> The wcn36xx wifi driver follows the life cycle of the WLAN_CTRL SMD
> channel, as such it should be a SMD client. This patch makes this
> transition, now that we have the necessary frameworks available.
>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
>
> Changes since v3:
> - Made msg_header const in wcn36xx_smd_rsp_process()
>
> Changes since v2:
> - Correct the call to the new ieee80211_scan_completed()
>
>  drivers/net/wireless/ath/wcn36xx/dxe.c     | 16 +++---
>  drivers/net/wireless/ath/wcn36xx/main.c    | 79 ++++++++++++++++++++----------
>  drivers/net/wireless/ath/wcn36xx/smd.c     | 31 +++++-------
>  drivers/net/wireless/ath/wcn36xx/smd.h     |  5 ++
>  drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 21 +++-----
>  5 files changed, 86 insertions(+), 66 deletions(-)

So I don't actually need to enable COMPILE_TEST anymore? Nice, thanks.

-- 
Kalle Valo
