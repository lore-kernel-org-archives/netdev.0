From: David Miller <davem@davemloft.net>
Subject: Re: ip6tables filter breakage.
Date: Wed, 06 Aug 2014 13:13:54 -0700 (PDT)
Message-ID: <20140806.131354.1888027200650409969.davem@davemloft.net>
References: <20140806195222.GA10618@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502AbaHFUN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 16:13:57 -0400
In-Reply-To: <20140806195222.GA10618@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 6 Aug 2014 15:52:22 -0400

CC:'ing netfilter-devel, Dave please do this in the future for
netfilter reports, thanks.

> After updating to Linus' current tree with todays net/ merge,
> I noticed that ip6tables doesn't work any more..
> 
> # ip6tables -F
> ip6tables v1.4.19.1: can't initialize ip6tables table `filter': No
> chain/target/match by that name
> Perhaps ip6tables or your kernel needs to be upgraded
> 
> My config has CONFIG_IP6_NF_FILTER=m
> I also note that ip6table_filter.ko doesn't get auto-loaded now.
> But even after modprobing it, I get the same message.
> 
> Is there some additional option I now need to enable ?
> 
> 
> I was a little surprised by how CONFIG_NF_TABLES is mandatory
> for iptables to keep working, even if you don't have nft userspace.
> (The only relevant thing in the Kconfig was related to x_tables,
>  which I wasn't using).
> 
> Perhaps either some select's, or additional help text ?
> 
> 	Dave
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
