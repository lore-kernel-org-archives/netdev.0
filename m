From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] mpls: packet stats
Date: Tue, 16 Feb 2016 15:08:13 -0500 (EST)
Message-ID: <20160216.150813.617905734698506558.davem@davemloft.net>
References: <1454700472-13543-2-git-send-email-rshearma@brocade.com>
	<20160206105843.GA27535@electric-eye.fr.zoreil.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CCDAD79@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, rshearma@brocade.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, ebiederm@xmission.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbcBPUIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:08:15 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCDAD79@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 8 Feb 2016 11:51:34 +0000

> From: Francois Romieu
>> Sent: 06 February 2016 10:59
>> > +void mpls_stats_inc_outucastpkts(struct net_device *dev,
>> > +				 const struct sk_buff *skb)
>> > +{
>> > +	struct mpls_dev *mdev;
>> > +	struct inet6_dev *in6dev;
>> 
>> Nit: the scope can be reduced for both variables.
> 
> And hiding the definitions of variables in the middle of
> functions just makes them harder to find.	

I completely disagree.  You look up from the scope you are reading back
to the top-level scope to fine variable declarations.

If the variable declarations are closer to where you are looking you
don't even need to scroll back at all.

It also happens to help the compiler run more efficiently.
