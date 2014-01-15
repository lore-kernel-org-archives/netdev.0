From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make dev_set_mtu() honor notification
 return code
Date: Wed, 15 Jan 2014 13:48:59 -0800 (PST)
Message-ID: <20140115.134859.1933462435423703835.davem@davemloft.net>
References: <1389358097-5396-1-git-send-email-vfalico@redhat.com>
	<20140113.151855.1046745397621207165.davem@davemloft.net>
	<20140114121354.GI4132@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, edumazet@google.com,
	alexander.h.duyck@intel.com, nicolas.dichtel@6wind.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbaAOVtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 16:49:00 -0500
In-Reply-To: <20140114121354.GI4132@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 14 Jan 2014 13:13:54 +0100

> As, currently, only team can signal NOTIFY_BAD on mtu change, it's
> really easy to implement. What do you think?

Looks great, and I agree that RTNL should solve all the other issues.
