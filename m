From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 3/3] ipv6: add ip6_flowlabel_consistency
 sysctl
Date: Wed, 15 Jan 2014 16:52:37 -0800 (PST)
Message-ID: <20140115.165237.1029263216450361441.davem@davemloft.net>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<1389785403-6401-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaAPAwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 19:52:38 -0500
In-Reply-To: <1389785403-6401-3-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Wed, 15 Jan 2014 12:30:03 +0100

> +			if (net->ipv6.sysctl.ip6_flowlabel_consistency) {
> +				pr_info("Can not set IPV6_FL_F_REFLECT if ip6_flowlabel_consistency sysctl is enable \n");

As others have mentioned, please ratelimit this.
