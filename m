From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [v5,1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
Date: Thu, 12 Jan 2017 11:47:40 +0100
Message-ID: <3591936e6ea64d71a1e5fadc33f43dd3@euamsexm01a.eu.qualcomm.com>
References: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Andy Gross <andy.gross@linaro.org>,
        <wcn36xx@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-msm@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:60450 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750912AbdALKsN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 05:48:13 -0500
In-Reply-To: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> The correct include file for getting errno constants and ERR_PTR() is
> linux/err.h, rather than linux/errno.h, so fix the include.
> 
> Fixes: e8b123e60084 ("soc: qcom: smem_state: Add stubs for disabled smem_state")
> Acked-by: Andy Gross <andy.gross@linaro.org>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

5 patches applied to ath-next branch of ath.git, thanks.

6c0b2e833f14 soc: qcom: smem_state: Fix include for ERR_PTR()
f303a9311065 wcn36xx: Transition driver to SMD client
886039036c20 wcn36xx: Implement firmware assisted scan
43efa3c0f241 wcn36xx: Implement print_reg indication
d53628882255 wcn36xx: Don't use the destroyed hal_mutex

-- 
https://patchwork.kernel.org/patch/9429045/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
