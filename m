From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH] wcn36xx: Set SMD timeout to 10 seconds
Date: Thu, 21 Apr 2016 14:11:06 -0700
Message-ID: <CALAqxLU8isySuMb-czb+9ZeUX03ygEEbtKH7yLui5K9zHK0DJA@mail.gmail.com>
References: <1461272982-7233-1-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461272982-7233-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2016 at 2:09 PM, Bjorn Andersson
<bjorn.andersson@linaro.org> wrote:
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

I've been using this with my nexus7 tree, and its avoided issues I was
seeing without it.

Tested-by: John Stultz <john.stultz@linaro.org>

thanks
-john
