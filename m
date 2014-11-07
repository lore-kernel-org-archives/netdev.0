From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 09/10] rocker: implement rocker ofdpa flow
 table manipulation
Date: Fri, 07 Nov 2014 15:16:07 -0500 (EST)
Message-ID: <20141107.151607.480474516800359791.davem@davemloft.net>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	<1415265610-9338-10-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbaKGUQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:16:18 -0500
In-Reply-To: <1415265610-9338-10-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  6 Nov 2014 10:20:09 +0100

> +#define ROCKER_OP_FLAG_REMOVE		(1 << 0)
> +#define ROCKER_OP_FLAG_NOWAIT		(1 << 1)
> +#define ROCKER_OP_FLAG_LEARNED		(1 << 2)

These can be defined to BIT(0), BIT(1), BIT(2).

> +	hash_for_each_possible(rocker->group_tbl, found,
> +			       entry, match->group_id)
> +		if (found->group_id == match->group_id)
> +			return found;

Please enclose multi-line basic blocks inside of curly braces.
