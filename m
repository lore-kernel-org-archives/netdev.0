From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Fix corrupted queue_mapping
Date: Thu, 07 Jun 2012 23:15:01 -0700 (PDT)
Message-ID: <20120607.231501.463746858434969001.davem@davemloft.net>
References: <1339135057.6001.20.camel@edumazet-glaptop>
	<20120607.230216.2014005732863772019.davem@davemloft.net>
	<1339135881.6001.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301Ab2FHGPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 02:15:03 -0400
In-Reply-To: <1339135881.6001.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jun 2012 08:11:21 +0200

> On Thu, 2012-06-07 at 23:02 -0700, David Miller wrote:
>> Hmmm, isn't that what qdisc_skb_cb is for?  And even private data is
>> explicitly allocated:
>> 
>> >  	unsigned char		data[24];
>> 
>> there. :-)
>> 
> 
> Yes, but some other layers can use the same trick so it might collide.
> 
> Inserting the bond field in qdisc_skb_cb (level0) is safer.

Do you suggest that Infiniband does the same thing? :-)
