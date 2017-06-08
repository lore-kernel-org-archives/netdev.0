From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next v2 01/19] net: switchdev: Add support for
 querying supported bridge flags by hardware
Date: Thu, 8 Jun 2017 11:30:13 +0200
Message-ID: <c0568608-38ba-16cc-3707-affa14a74d52@redhat.com>
References: <20170608064428.4785-1-jiri@resnulli.us>
 <20170608064428.4785-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750822AbdFHJaV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 05:30:21 -0400
In-Reply-To: <20170608064428.4785-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8.6.2017 08:44, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> This is done as a preparation stage before setting the bridge port flags
> from the bridge code. Currently the device can be queried for the bridge
> flags state, but the querier cannot distinguish if the flag is disabled
> or if it is not supported at all. Thus, add new attr and a bit-mask which
> include information regarding the support on a per-flag basis.
> 
> Drivers that support bridge offload but not support bridge flags should
> return zeroed bitmask.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Ivan Vecera <ivecera@redhat.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/switchdev.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 929d6af..63a754d 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -46,6 +46,7 @@ enum switchdev_attr_id {
>  	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
>  	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>  	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
> +	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT,
>  	SWITCHDEV_ATTR_ID_PORT_MROUTER,
>  	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>  	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
> @@ -62,6 +63,7 @@ struct switchdev_attr {
>  		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
>  		u8 stp_state;				/* PORT_STP_STATE */
>  		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
> +		unsigned long brport_flags_support;	/* PORT_BRIDGE_FLAGS_SUPPORT */
>  		bool mrouter;				/* PORT_MROUTER */
>  		clock_t ageing_time;			/* BRIDGE_AGEING_TIME */
>  		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
> 

Reviewed-by: Ivan Vecera <ivecera@redhat.com>
