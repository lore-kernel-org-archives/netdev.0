From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Thu, 12 Dec 2013 12:22:41 -0500 (EST)
Message-ID: <20131212.122241.2022824170198915190.davem@davemloft.net>
References: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com>
	<20131211192138.GB4675@order.stressinduktion.org>
	<52A99B56.1070503@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jpirko@redhat.com
To: dvlasenk@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700Ab3LLRWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 12:22:44 -0500
In-Reply-To: <52A99B56.1070503@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Thu, 12 Dec 2013 12:17:42 +0100

> I can easily imagine their frustration. Kernel _knows_ why
> it didn't work, and it's not expected to normally pappen,
> why didn't it tell anything about it?

Packets are dropped silently, ARP fails and entries go stale silently,
none of this is logged with kernel messages, why is ipv6 autoconf so
unique and important to justify different behavior?

Give it statistics just like we have for every other kind of similar
event.
