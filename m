From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Wed, 26 Jul 2006 23:02:30 -0700 (PDT)
Message-ID: <20060726.230230.111423566.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221849.807482409@postel.suug.ch>
	<Pine.LNX.4.64.0607270158001.4779@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24284
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932489AbWG0GCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 02:02:10 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607270158001.4779@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 27 Jul 2006 01:58:58 -0400 (EDT)

> On Thu, 27 Jul 2006, Thomas Graf wrote:
> 
> > +	rule = kmalloc(ops->rule_size, GFP_KERNEL);
> > +	if (rule == NULL) {
> > +		err = -ENOMEM;
> > +		goto errout;
> > +	}
> > +	memset(rule, 0, ops->rule_size);
> > +
> 
> kzalloc() ? :-)

Good catch :)  He did use kzalloc() in a few other places, to his
credit.
