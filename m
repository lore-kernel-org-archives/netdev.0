From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 10/14] net; ethernet: ti: cpsw: move irq stuff under
 cpsw_common
Date: Tue, 9 Aug 2016 18:43:54 +0300
Message-ID: <c419e923-df0a-f22b-ee1d-f0f5b7165aca@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-11-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-11-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2016 01:48 PM, Ivan Khoronzhuk wrote:
> The irq data are common per net device. So no need to hold these

May be rephrase it a bit.

> data per net dev, move it under cpsw_common. Also delete irq_num
> var, as after optimization it's not needed. Correct number of
> irqs to 2, as anyway, driver is using only 2, at least for now.
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 65 +++++++++++++++++++-----------------------
>  1 file changed, 29 insertions(+), 36 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c

>



-- 
regards,
-grygorii
