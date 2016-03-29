From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 15/16] wcn36xx: don't pad beacons for mesh
Date: Tue, 29 Mar 2016 15:45:57 +0300
Message-ID: <56FA7905.80902@cogentembedded.com>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
 <1459231593-360-16-git-send-email-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Mobarak <jam@cozybit.com>,
	Chun-Yeow Yeoh <yeohchunyeow@cozybit.com>
To: Bjorn Andersson <bjorn.andersson@linaro.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459231593-360-16-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/29/2016 9:06 AM, Bjorn Andersson wrote:

> From: Jason Mobarak <jam@cozybit.com>
>
> Patch "wcn36xx: Pad TIM PVM if needed" has caused a regression in mesh

    scripts/checkpatch.pl now enforces the specific commit citing format, i.e. 
<12-digit SHA1> ("<commit summary>").

> beaconing.  The field tim_off is always 0 for mesh mode, and thus
> pvm_len (referring to the TIM length field) and pad are both incorrectly
> calculated.  Thus, msg_body.beacon_length is incorrectly calculated for
> mesh mode. Fix this.
>
> Signed-off-by: Jason Mobarak <jam@cozybit.com>
> Signed-off-by: Chun-Yeow Yeoh <yeohchunyeow@cozybit.com>
> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>

    You might want to add the Fixes: tag.

[...]

MBR, Sergei
