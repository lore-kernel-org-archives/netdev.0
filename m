From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tun: spelling fixes
Date: Fri, 06 Dec 2013 12:46:38 +0800
Message-ID: <52A156AE.9020200@redhat.com>
References: <20131205204258.5eb404b2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752157Ab3LFEqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Dec 2013 23:46:54 -0500
In-Reply-To: <20131205204258.5eb404b2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 12:42 PM, Stephen Hemminger wrote:
> Fix spelling errors in tun driver.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>
> --- a/drivers/net/tun.c	2013-12-05 14:47:25.820499591 -0800
> +++ b/drivers/net/tun.c	2013-12-05 14:55:37.032476288 -0800
> @@ -110,7 +110,7 @@ struct tap_filter {
>  	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
>  };
>  
> -/* DEFAULT_MAX_NUM_RSS_QUEUES were choosed to let the rx/tx queues allocated for
> +/* DEFAULT_MAX_NUM_RSS_QUEUES were chosen to let the rx/tx queues allocated for
>   * the netdevice to be fit in one page. So we can make sure the success of
>   * memory allocation. TODO: increase the limit. */
>  #define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
> @@ -119,7 +119,7 @@ struct tap_filter {
>  #define TUN_FLOW_EXPIRE (3 * HZ)
>  
>  /* A tun_file connects an open character device to a tuntap netdevice. It
> - * also contains all socket related strctures (except sock_fprog and tap_filter)
> + * also contains all socket related structures (except sock_fprog and tap_filter)
>   * to serve as one transmit queue for tuntap device. The sock_fprog and
>   * tap_filter were kept in tun_struct since they were used for filtering for the
>   * netdevice not for a specific queue (at least I didn't see the requirement for
> @@ -342,7 +342,7 @@ unlock:
>  }
>  
>  /* We try to identify a flow through its rxhash first. The reason that
> - * we do not check rxq no. is becuase some cards(e.g 82599), chooses
> + * we do not check rxq no. is because some cards(e.g 82599), chooses
>   * the rxq based on the txq where the last packet of the flow comes. As
>   * the userspace application move between processors, we may get a
>   * different rxq no. here. If we could not get rxhash, then we would
> @@ -531,7 +531,7 @@ static int tun_attach(struct tun_struct
>  
>  	err = 0;
>  
> -	/* Re-attach the filter to presist device */
> +	/* Re-attach the filter to persist device */
>  	if (!skip_filter && (tun->filter_attached == true)) {
>  		err = sk_attach_filter(&tun->fprog, tfile->socket.sk);
>  		if (!err)
> @@ -819,9 +819,9 @@ static void tun_poll_controller(struct n
>  	 * Tun only receives frames when:
>  	 * 1) the char device endpoint gets data from user space
>  	 * 2) the tun socket gets a sendmsg call from user space
> -	 * Since both of those are syncronous operations, we are guaranteed
> +	 * Since both of those are synchronous operations, we are guaranteed
>  	 * never to have pending data when we poll for it
> -	 * so theres nothing to do here but return.
> +	 * so there is nothing to do here but return.
>  	 * We need this though so netpoll recognizes us as an interface that
>  	 * supports polling, which enables bridge devices in virt setups to
>  	 * still use netconsole
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Acked-by: Jason Wang <jasowang@redhat.com>
