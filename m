From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next RFC 1/9] net_sch: red: Add offload ability to
 RED qdisc
Date: Mon, 30 Oct 2017 21:20:15 +0900 (KST)
Message-ID: <20171030.212015.742241045938302800.davem@davemloft.net>
References: <20171030085613.8697-1-jiri@resnulli.us>
        <20171030085613.8697-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751814AbdJ3MU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 08:20:29 -0400
In-Reply-To: <20171030085613.8697-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 30 Oct 2017 09:56:05 +0100

> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> index 0e88cc2..743c42a 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -255,6 +255,7 @@ struct tc_red_qopt {
>  #define TC_RED_ECN		1
>  #define TC_RED_HARDDROP		2
>  #define TC_RED_ADAPTATIVE	4
> +#define TC_RED_OFFLOADED	8
>  };
>  
>  struct tc_red_xstats {

What keeps a user from setting this flag in the tc_red_qopt it
passes into the a change operation?
