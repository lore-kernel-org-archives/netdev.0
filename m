From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: support ingress/egress priority map flushing
Date: Sun, 12 Mar 2017 23:30:14 -0700 (PDT)
Message-ID: <20170312.233014.417497020070639639.davem@davemloft.net>
References: <4d3ee617-df9d-eed7-ced6-1458b3f92a1a@dtsystems.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: thierry@dtsystems.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53722 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdCMGaQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:30:16 -0400
In-Reply-To: <4d3ee617-df9d-eed7-ced6-1458b3f92a1a@dtsystems.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thierry Du Tre <thierry@dtsystems.be>
Date: Fri, 10 Mar 2017 15:41:35 +0100

> --- a/include/uapi/linux/if_vlan.h
> +++ b/include/uapi/linux/if_vlan.h
> @@ -20,6 +20,8 @@
>  enum vlan_ioctl_cmds {
>  	ADD_VLAN_CMD,
>  	DEL_VLAN_CMD,
> +	FLUSH_VLAN_INGRESS_PRIORITY_CMD,
> +	FLUSH_VLAN_EGRESS_PRIORITY_CMD,
>  	SET_VLAN_INGRESS_PRIORITY_CMD,
>  	SET_VLAN_EGRESS_PRIORITY_CMD,
>  	GET_VLAN_INGRESS_PRIORITY_CMD,

You definitely cannot insert new command values in the middle of
existing commands, this changes the value of SET/GET/etc. thus
breaking existing userspace.
