From: "Valo, Kalle" <kvalo@qca.qualcomm.com>
Subject: Re: [v5,1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
Date: Tue, 22 Nov 2016 14:55:04 +0000
Message-ID: <877f7vimyg.fsf@kamboji.qca.qualcomm.com>
References: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
        <a4095c49fe5a42c4a405b1faf6c0f3b7@euamsexm01a.eu.qualcomm.com>
        <20161118183541.GI28340@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "k.eugene.e@gmail.com" <k.eugene.e@gmail.com>,
        Andy Gross <andy.gross@linaro.org>,
        "wcn36xx@lists.infradead.org" <wcn36xx@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20161118183541.GI28340@tuxbot> (Bjorn Andersson's message of
        "Fri, 18 Nov 2016 10:35:41 -0800")
Content-Language: en-US
Content-ID: <7912ABFCDB849344A2AB905FBA5FE275@qualcomm.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> On Wed 16 Nov 10:49 PST 2016, Kalle Valo wrote:
>
>> Bjorn Andersson <bjorn.andersson@linaro.org> wrote:
>> > The correct include file for getting errno constants and ERR_PTR() is
>> > linux/err.h, rather than linux/errno.h, so fix the include.
>> >=20
>> > Fixes: e8b123e60084 ("soc: qcom: smem_state: Add stubs for disabled sm=
em_state")
>> > Acked-by: Andy Gross <andy.gross@linaro.org>
>> > Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
>>=20
>> For some reason this fails to compile now. Can you take a look, please?
>>=20
>> ERROR: "qcom_wcnss_open_channel" [drivers/net/wireless/ath/wcn36xx/wcn36=
xx.ko] undefined!
>> make[1]: *** [__modpost] Error 1
>> make: *** [modules] Error 2
>>=20
>> 5 patches set to Changes Requested.
>>=20
>> 9429045 [v5,1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
>> 9429047 [v5,2/5] wcn36xx: Transition driver to SMD client
>
> This patch was updated with the necessary depends in Kconfig to catch
> this exact issue and when I pull in your .config (which has QCOM_SMD=3Dn,
> QCOM_WCNSS_CTRL=3Dn and WCN36XX=3Dy) I can build this just fine.
>
> I've tested the various combinations and it seems to work fine. Do you
> have any other patches in your tree?

This was with the pending branch of my ath.git tree. There are other
wireless patches (ath10k etc) but I would guess they don't affect here.

> Any stale objects?

Not sure what you mean with this question, but I didn't run 'make clean'
if that's what you are asking.

> Would you mind retesting this, before I invest more time in trying to
> reproduce the issue you're seeing?

Sure, I'll take a look but that might take few days.

--=20
Kalle Valo=
