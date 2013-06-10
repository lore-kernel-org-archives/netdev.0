From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] doc:networking: Update comment for dev_id
 field in netdevice.h
Date: Mon, 10 Jun 2013 17:11:10 +0100
Message-ID: <1370880670.1933.9.camel@bwh-desktop.uk.level5networks.com>
References: <20130610140325.GA1383@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11228 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3FJQLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 12:11:15 -0400
In-Reply-To: <20130610140325.GA1383@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-10 at 19:34 +0530, Narendra_K@Dell.com wrote:
> This patch updates the comment for 'dev_id' field in
> 'include/linux/netdevice.h' to reflect the intended
> usage of 'dev_id'.
> 
> References: http://marc.info/?l=linux-netdev&m=136992115300526&w=2
> References: http://marc.info/?l=linux-netdev&m=137062569014612&w=2
> 
> Signed-off-by: Narendra K <narendra_k@dell.com>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  include/linux/netdevice.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8f967e3..a43712e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1142,8 +1142,10 @@ struct net_device {
>  	unsigned char		addr_assign_type; /* hw address assignment type */
>  	unsigned char		addr_len;	/* hardware address length	*/
>  	unsigned char		neigh_priv_len;
> -	unsigned short          dev_id;		/* for shared network cards */
> -
> +	unsigned short          dev_id;		/* Used to differentiate devices
> +						 * that share the same link
> +						 * layer address
> +						 */
>  	spinlock_t		addr_list_lock;
>  	struct netdev_hw_addr_list	uc;	/* Unicast mac addresses */
>  	struct netdev_hw_addr_list	mc;	/* Multicast mac addresses */
> -- 
> 1.8.0.1
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
