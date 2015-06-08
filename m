From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 15:21:44 -0700 (PDT)
Message-ID: <20150608.152144.109876458001741914.davem@davemloft.net>
References: <1433793517.4616.4.camel@stressinduktion.org>
	<20150608.150518.424856528462798668.davem@davemloft.net>
	<1433801588.2014273.290219489.63F713EC@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, nicolas.dichtel@6wind.com,
	dsahern@gmail.com, ebiederm@xmission.com, hadi@mojatatu.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60872 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932328AbbFHWVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:21:45 -0400
In-Reply-To: <1433801588.2014273.290219489.63F713EC@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 09 Jun 2015 00:13:08 +0200

> It is easy to move the rt_table_id to net_device and use the same
> one for IPv6.  This would force people to build symmetric routing
> configurations. I was striving for maximum flexibility first but I
> don't really think this matters here.

Alternatively you could have __ipv4_idev_rt_table(idev) and implement
ipv4_idev_rt_table() in terms of that.
