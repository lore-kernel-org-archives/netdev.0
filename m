From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] ath10k: remove unused <linux/semaphore.h>
Date: Tue, 21 Jun 2016 16:46:00 +0300
Message-ID: <bf7b2008-b333-2d79-a952-fda895da8479@cogentembedded.com>
References: <20160621114539.15313-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 ath10k@lists.infradead.org
To: Chaehyun Lim <chaehyun.lim@gmail.com>, kvalo@qca.qualcomm.com
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160621114539.15313-1-chaehyun.lim@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello.

On 6/21/2016 2:45 PM, Chaehyun Lim wrote:

> <linux/semaphore.h> is not used anymore, so just remove it.

    s/it/#include/?

> Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>
[...]

> diff --git a/drivers/net/wireless/ath/ath10k/htc.h b/drivers/net/wireless/ath/ath10k/htc.h
> index cc82718..0c55cd9 100644
> --- a/drivers/net/wireless/ath/ath10k/htc.h
> +++ b/drivers/net/wireless/ath/ath10k/htc.h
> @@ -22,7 +22,6 @@
>  #include <linux/list.h>
>  #include <linux/bug.h>
>  #include <linux/skbuff.h>
> -#include <linux/semaphore.h>
>  #include <linux/timer.h>
>
>  struct ath10k;

MBR, Sergei
