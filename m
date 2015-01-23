From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Fri, 23 Jan 2015 01:04:21 -0800 (PST)
Message-ID: <20150123.010421.413293636634640915.davem@davemloft.net>
References: <54C03A57.4080002@6wind.com>
	<CA+mtBx9pnkJBVftqFTK6fcd-toAxsJrvB=drTxWQs_=5s9C0+A@mail.gmail.com>
	<54C138BB.7000407@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse@nicira.com, pshelar@nicira.com,
	netdev@vger.kernel.org
To: vincent.jardin@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46256 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbbAWJEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 04:04:22 -0500
In-Reply-To: <54C138BB.7000407@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent JARDIN <vincent.jardin@6wind.com>
Date: Thu, 22 Jan 2015 18:51:55 +0100

> Same: LRO/GRO is is bad features: it breaks many times networking
> (most IP forwarders must disable it), but it helps for servers. Same
> for STT in fact, it has its narrow set of use-cases which are valid.

False, GRO helps for forwarders too, because it decreases the number
of IP route lookups, one of the most expensive operations during
formwarding.

Please do not spread misinformation, and especially do not try to show
that GRO is in _ANY_ way something like STT.  That's completely wrong.
