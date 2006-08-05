From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Sat, 05 Aug 2006 02:21:11 -0700 (PDT)
Message-ID: <20060805.022111.17843589.davem@davemloft.net>
References: <20060804102308.711837665@postel.suug.ch>
	<20060804102636.322297243@postel.suug.ch>
	<44D45E34.9030607@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7627
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422772AbWHEJVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 05:21:03 -0400
To: kaber@trash.net
In-Reply-To: <44D45E34.9030607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 05 Aug 2006 11:00:36 +0200

> Thomas Graf wrote:
> > +	if (rt->rt6i_table)
> > +		rtm->rtm_table = rt->rt6i_table->tb6_id;
> > +	else
> > +		rtm->rtm_table = RT6_TABLE_UNSPEC;
> >  	rtm->rtm_table = RT_TABLE_MAIN;
> 
> 
> This looks like a mistake, the table ID is overwritten again.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Good catch Patrick, patch applied.

Thanks a lot.
