From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [net-next PATCH 3/6] macvtap: remove the dead branch
Date: Thu, 05 Dec 2013 22:08:20 -0800
Message-ID: <52A169D4.4060209@roeck-us.net>
References: <1386282527-14094-1-git-send-email-zwu.kernel@gmail.com> <1386282527-14094-4-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386282527-14094-4-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/05/2013 02:28 PM, Zhi Yong Wu wrote:
> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> ---
>   drivers/net/macvtap.c |    2 --
>   1 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 9093004..d271fb4 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -779,8 +779,6 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>   			return -EINVAL;
>
>   		ret = macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
> -		if (ret)
> -			return ret;
>
Assigning the function's return value to ret just to ignore it seems odd.

Might make sense to change the function type to void.

Guenter
