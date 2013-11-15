From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] bonding: add ip checks when store ip target
Date: Fri, 15 Nov 2013 17:44:57 -0500 (EST)
Message-ID: <20131115.174457.1747641547874304346.davem@davemloft.net>
References: <52857FE2.5060400@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981Ab3KOWo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 17:44:59 -0500
In-Reply-To: <52857FE2.5060400@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Fri, 15 Nov 2013 09:58:58 +0800

> From 513509eecdee98d72668219aead9784d56dbad0f Mon Sep 17 00:00:00 2001
> From: Wang Weidong <wangweidong1@huawei.com>
> Date: Fri, 15 Nov 2013 10:34:30 -0500
> Subject: [PATCH] bonding: add ip checks when store ip target
> 
> I met a Bug when I add ip target with the wrong ip address:
> 
> echo +500.500.500.500 > /sys/class/net/bond0/bonding/arp_ip_target
> 
> the wrong ip address will transfor to 245.245.245.244 and add
> to the ip target success, it is uncorrect, so I add checks to avoid
> adding wrong address.
> 
> The in4_pton() will set wrong ip address to 0.0.0.0, it will return by
> the next check and will not add to ip target.
> 
> v2
> According Veaceslav's opinion, simplify the code.
> 
> v3
> According Veaceslav's opinion, add broadcast check and make a micro
> definition to package it.
> 
> v4
> Solve the problem of the format which David point out.
> 
> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied, thanks.
