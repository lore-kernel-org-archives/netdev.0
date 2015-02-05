From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Thu, 05 Feb 2015 15:12:24 +0300
Message-ID: <54D35E28.8010802@cogentembedded.com>
References: <1423120837-28102-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eulfsam <ulf.samuelsson@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>,
	WANG Cong <xiyou.wangcong@gmail.com>
To: zhuyj <zyjzyj2000@gmail.com>, netdev@vger.kernel.org,
	stefan.costandache@windriver.com, alexandre.dietsch@windriver.com,
	yue.tao@windriver.com, clinton.slabbert@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:44580 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbbBEMM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 07:12:28 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so5681315lbi.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 04:12:26 -0800 (PST)
In-Reply-To: <1423120837-28102-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/5/2015 10:20 AM, zhuyj wrote:

> From: eulfsam <ulf.samuelsson@ericsson.com>

> When the neighbor statemachine is in PROBE state, it will normally send

    State machine.

> a number of unicast ARP requests (number defined in "ucast_probes" entry
> in the proc file system, default=3) and if no reply is received, it will
> change state to FAILED.

> Enabling CONFIG_ARP_PROBE_BCAST, will make the statemachine try to send

    Likewise.

> broadcast ARP requests, and only enter FAILED state if the broadcast ARP
> requests did not receive a reply.

> Enabling CONFIG_ARP_PROBE_BCAST, makes the IPv4 ARP behaviour more
> similar to the IPv6 Neighbor Discovery protocol, and is neccessary,

    Necessary.

> if the other end only responds to broadcast ARPs.

> CC: David S. Miller <davem@davemloft.net>
> CC: WANG Cong <xiyou.wangcong@gmail.com>
> Signed-off-by: eulfsam <ulf.samuelsson@ericsson.com>
> Signed-off-by: zhuyj <zyjzyj2000@gmail.com>

    Need real names here.

[...]

> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index bd29016..4d13edb 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -259,6 +259,23 @@ config IP_PIMSM_V2
>   	  gated-5). This routing protocol is not used widely, so say N unless
>   	  you want to play with it.
>
> +config ARP_PROBE_BCAST
> +	bool "IP: ARP send broadcast ARP, if probing using unicast fails"
> +	default	y
> +	---help---
> +	  When the neighbor statemachine is in PROBE state, it will

    State machine.

> +	  normally send a number of unicast ARP requests
> +	  (number defined in "ucast_probes" entry in the proc file system, default=3)
> +	  and if no reply is received, it will change state to FAILED.
> +
> +	  Saying Y here, will make the statemachine try to send broadcast ARP

    Likewise.

> +	  requests, and only enter FAILED state if the broadcast ARP requests did not
> +	  receive a reply.
> +
> +	  Enabling this, makes the IPv4 ARP behaviour more similar to the IPv6
> +	  Neighbor Discovery protocol, and is neccessary, if the other end

    Necessary.

[...]

WBR, Sergei
