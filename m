From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v4 1/4] soc: qcom: wcnss_ctrl: Stub wcnss_ctrl API
Date: Wed, 07 Sep 2016 14:33:28 +0300
Message-ID: <874m5sx7uf.fsf@kamboji.qca.qualcomm.com>
References: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
        <20160907013958.GA6975@hector.attlocal.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org,
        Marcel Holtmann <marcel@holtmann.org>
To: Andy Gross <andy.gross@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20160907013958.GA6975@hector.attlocal.net> (Andy Gross's message
        of "Tue, 6 Sep 2016 20:39:58 -0500")
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gross <andy.gross@linaro.org> writes:

> On Tue, Sep 06, 2016 at 03:18:29PM -0700, Bjorn Andersson wrote:
>> Stub the wcnss_ctrl API to allow compile testing wcnss function drivers.
>> 
>> Cc: Marcel Holtmann <marcel@holtmann.org>
>> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
>> ---
>> 
>> There are no other pending changes colliding with this, so if Andy is okay with
>> this it could be merged through Kalle's tree - together with the other patches.
>> 
>> Marcel, with this applied we can drop the depends on QCOM_SMD from the
>> btqcomsmd driver as well.
>> 
>> Changes since v3:
>> - Added this patch to allow compile testing without SMD support after patch 2
>> 
>>  include/linux/soc/qcom/wcnss_ctrl.h | 13 +++++++++++++
>>  1 file changed, 13 insertions(+)
>> 
>
> This is fine.
>
> Acked-by: Andy Gross <andy.gross@linaro.org>

Thanks. I'll then apply this to my ath.git tree and it will go to Linus
via net-next.

-- 
Kalle Valo
