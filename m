From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH 3/3] batman-adv: Add missing kerneldoc for extack
Date: Sat, 7 Oct 2017 08:23:44 -0600
Message-ID: <514099d9-571b-f1c3-11a3-46f759cccc0d@gmail.com>
References: <20171007121853.6278-1-sven@narfation.org>
 <20171007122122.6470-1-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>,
        b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37286 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdJGOXp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 10:23:45 -0400
Received: by mail-pg0-f66.google.com with SMTP id o1so19933888pga.4
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 07:23:44 -0700 (PDT)
In-Reply-To: <20171007122122.6470-1-sven@narfation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/17 6:21 AM, Sven Eckelmann wrote:
> The parameter extack was added to batadv_softif_slave_add without adding
> the kernel-doc for it. This caused kernel-doc warnings.
> 
> Signed-off-by: Sven Eckelmann <sven@narfation.org>
> Cc: David Ahern <dsahern@gmail.com>
> ---
>  net/batman-adv/soft-interface.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
> index 543d2c3e..9f673cdf 100644
> --- a/net/batman-adv/soft-interface.c
> +++ b/net/batman-adv/soft-interface.c
> @@ -863,6 +863,7 @@ static int batadv_softif_init_late(struct net_device *dev)
>   * batadv_softif_slave_add - Add a slave interface to a batadv_soft_interface
>   * @dev: batadv_soft_interface used as master interface
>   * @slave_dev: net_device which should become the slave interface
> + * @extack: extended ACK report struct
>   *
>   * Return: 0 if successful or error otherwise.
>   */
> 

Thanks for the cleanup.

Acked-by: David Ahern <dsahern@gmail.com>
