From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 19:12:34 -0700 (PDT)
Message-ID: <20110621.191234.1252718817049863482.davem@davemloft.net>
References: <4E009C5A.8060208@inliniac.net>
	<20110621.143902.274396574751811372.davem@davemloft.net>
	<BANLkTinxvHbkCLehJkqoCfryeTqL0zhWiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757737Ab1FVCMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 22:12:43 -0400
In-Reply-To: <BANLkTinxvHbkCLehJkqoCfryeTqL0zhWiw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 22 Jun 2011 09:44:00 +0800

> I think he also needs all the packets belong to the related
> connections are received via the same socket. I am afraid that he has
> to dispatch these kind of packets among the uesrland processes again.
> :)

I mean, if we really wanted to, we could create a new ip_defrag()
client case in the rxhash receive code.  But this would need to be
configurable and off by default.

It would provide the desired behavior.
