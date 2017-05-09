From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wcn36xx: Close SMD channel on device removal
Date: Tue, 09 May 2017 09:17:05 +0300
Message-ID: <87h90u3672.fsf@kamboji.qca.qualcomm.com>
References: <20170509043637.28179-1-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Eyal Ilsar <c_eilsar@qti.qualcomm.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509043637.28179-1-bjorn.andersson@linaro.org> (Bjorn
        Andersson's message of "Mon, 8 May 2017 21:36:37 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

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

As this is a regression I'll queue this to 4.12.

But if this is an older bug (didn't quite understand your description
though) should there be a separate patch for stable releases?

-- 
Kalle Valo
