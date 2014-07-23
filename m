From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v8 3/6] openvswitch: Add hash action
Date: Wed, 23 Jul 2014 14:42:48 -0700 (PDT)
Message-ID: <20140723.144248.119709569087635224.davem@davemloft.net>
References: <1406054089-1700-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, azhou@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38051 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbaGWVmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:42:51 -0400
In-Reply-To: <1406054089-1700-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 22 Jul 2014 11:34:49 -0700

> OVS_ACTION_ATTR_HASH is set to 10 to maintain compatibility with
> existing userspace API.

I don't understand this.

> @@ -521,6 +544,7 @@ enum ovs_action_attr {
>  	OVS_ACTION_ATTR_PUSH_VLAN,    /* struct ovs_action_push_vlan. */
>  	OVS_ACTION_ATTR_POP_VLAN,     /* No argument. */
>  	OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
> +	OVS_ACTION_ATTR_HASH = 10,     /* struct ovs_action_hash. */
>  	__OVS_ACTION_ATTR_MAX
>  };

Do you have to force this to skip to '10' because of something
out-of-tree?  If so, that isn't a reasonable reason to do something
like this, sorry.
