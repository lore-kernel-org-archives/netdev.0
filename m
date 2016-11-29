From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next] macvtap: replace printk with netdev_err
Date: Tue, 29 Nov 2016 18:04:53 +0800
Message-ID: <68530b91-4548-f122-4b93-41ad4fc5de84@redhat.com>
References: <1480389992-69609-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756346AbcK2KE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Nov 2016 05:04:59 -0500
In-Reply-To: <1480389992-69609-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月29日 11:26, Zhang Shengju wrote:
> This patch replaces printk() with netdev_err() for macvtap device.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>   drivers/net/macvtap.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 5da9861..2513939 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -437,7 +437,7 @@ static int macvtap_get_minor(struct macvlan_dev *vlan)
>   	if (retval >= 0) {
>   		vlan->minor = retval;
>   	} else if (retval == -ENOSPC) {
> -		printk(KERN_ERR "too many macvtap devices\n");
> +		netdev_err(vlan->dev, "Too many macvtap devices\n");
>   		retval = -EINVAL;
>   	}
>   	mutex_unlock(&minor_lock);

Acked-by: Jason Wang <jasowang@redhat.com>
