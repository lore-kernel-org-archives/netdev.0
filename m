From: David Miller <davem@davemloft.net>
Subject: Re: [net] net_sched: make dev_trans_start return vlan's real dev
 trans_start
Date: Sat, 03 Aug 2013 12:37:18 -0700 (PDT)
Message-ID: <20130803.123718.860048633152323615.davem@davemloft.net>
References: <20130803170733.GA10218@redhat.com>
	<20130803.115228.1509916868029010372.davem@davemloft.net>
	<20130803190918.GA11976@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fubar@us.ibm.com,
	jhs@mojatatu.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab3HCThT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 15:37:19 -0400
In-Reply-To: <20130803190918.GA11976@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Sat, 3 Aug 2013 21:09:18 +0200

> I haven't found any usage for it, tbh. Only the vlan code itself
> might benefit from it, but it already uses the
> vlan_dev_priv(dev)->real_dev, and not the vlan_dev_real_dev(), which
> is used by drivers.

Agreed.
