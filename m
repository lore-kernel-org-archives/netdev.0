From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wcn36xx: Set SMD timeout to 10 seconds
Date: Wed, 27 Apr 2016 15:55:25 +0300
Message-ID: <8760v3w6rm.fsf@kamboji.qca.qualcomm.com>
References: <1461272982-7233-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461272982-7233-1-git-send-email-bjorn.andersson@linaro.org>
	(Bjorn Andersson's message of "Thu, 21 Apr 2016 14:09:42 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson <bjorn.andersson@linaro.org> writes:

> After booting the wireless subsystem and uploading the NV blob to the
> WCNSS_CTRL service the remote continues to do things and will not start
> servicing wlan-requests for another 2-5 seconds (measured).
>
> The downstream code does not have any special handling for this case,
> but has a timeout of 10 seconds for the communication layer. By
> extending the wcn36xx timeout to match this we follows the same flow for
> the boot procedure and can successfully configure WiFi as wlan0 is
> registered.
>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Applied, thanks.

-- 
Kalle Valo
