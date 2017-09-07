From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 3/4] devlink: Update devlink UAPI file
Date: Thu, 7 Sep 2017 15:12:58 -0700
Message-ID: <20170907151258.55a64309@xeon-e3>
References: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
        <1504794403-45690-4-git-send-email-arkadis@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch, Jiri Pirko <jiri@mellanox.com>
To: Arkadi Sharshevsky <arkadis@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:38067 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932238AbdIGWNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 18:13:06 -0400
Received: by mail-pg0-f45.google.com with SMTP id v66so1695930pgb.5
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 15:13:06 -0700 (PDT)
In-Reply-To: <1504794403-45690-4-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Sep 2017 17:26:42 +0300
Arkadi Sharshevsky <arkadis@mellanox.com> wrote:

> Update devlink UAPI file.
> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/devlink.h | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/include/linux/devlink.h b/include/linux/devlink.h
> index 7644005..a62695e 100644
> --- a/include/linux/devlink.h
> +++ b/include/linux/devlink.h
> @@ -226,4 +226,22 @@ enum devlink_dpipe_action_type {
>  	DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY,
>  };
>  
> +enum devlink_dpipe_field_ethernet_id {
> +	DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
> +};
> +
> +enum devlink_dpipe_field_ipv4_id {
> +	DEVLINK_DPIPE_FIELD_IPV4_DST_IP,
> +};
> +
> +enum devlink_dpipe_field_ipv6_id {
> +	DEVLINK_DPIPE_FIELD_IPV6_DST_IP,
> +};
> +
> +enum devlink_dpipe_header_id {
> +	DEVLINK_DPIPE_HEADER_ETHERNET,
> +	DEVLINK_DPIPE_HEADER_IPV4,
> +	DEVLINK_DPIPE_HEADER_IPV6,
> +};
> +
>  #endif /* _LINUX_DEVLINK_H_ */

This patch was unnecessary. Already had updated file present.
