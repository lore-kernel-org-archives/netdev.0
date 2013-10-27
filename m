From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in
 bonding
Date: Sun, 27 Oct 2013 17:44:58 -0400 (EDT)
Message-ID: <20131027.174458.627996500790326920.davem@davemloft.net>
References: <52688F33.30904@huawei.com>
	<20131027.163712.1324471504006808112.davem@davemloft.net>
	<20131027211048.GA557@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, netdev@vger.kernel.org
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672Ab3J0VpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 17:45:02 -0400
In-Reply-To: <20131027211048.GA557@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sun, 27 Oct 2013 22:10:48 +0100

> All the changelogs for the patches are *the same*, and, while they try
> to
> explain what's done overall, the don't explain what's done per-patch,
> why
> it's done and why is it safe to move those locks around.

He did say so, he listed in fact three alternative ways to fix the
locking problem and then explciitly stated which of the three he
choose.

I would have preferred that he did all of this in the initial 0/N
patch posting, but I can't defer forever.
