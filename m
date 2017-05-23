From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: wcn36xx: Close SMD channel on device removal
Date: Tue, 23 May 2017 17:23:48 +0200
Message-ID: <791ac0fefa814db68e482254b91e45ca@euamsexm01a.eu.qualcomm.com>
References: <20170509043637.28179-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Eyal Ilsar <c_eilsar@qti.qualcomm.com>,
        <wcn36xx@lists.infradead.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-arm-msm@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509043637.28179-1-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
> The SMD channel is not the primary WCNSS channel and must explicitly be
> closed as the device is removed, or the channel will already by open on
> a subsequent probe call in e.g. the case of reloading the kernel module.
> 
> This issue was introduced because I simplified the underlying SMD
> implementation while the SMD adaptions of the driver sat on the mailing
> list, but missed to update these patches. The patch does however only
> apply back to the transition to rpmsg, hence the limited Fixes.
> 
> Fixes: 5052de8deff5 ("soc: qcom: smd: Transition client drivers from smd to rpmsg")
> Reported-by: Eyal Ilsar <c_eilsar@qti.qualcomm.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Patch applied to ath-current branch of ath.git, thanks.

efad8396e906 wcn36xx: Close SMD channel on device removal

-- 
https://patchwork.kernel.org/patch/9717027/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
