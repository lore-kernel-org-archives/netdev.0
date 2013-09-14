From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual
 net_device
Date: Fri, 13 Sep 2013 20:16:26 -0400 (EDT)
Message-ID: <20130913.201626.1381750756413200302.davem@davemloft.net>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@aristanetworks.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755513Ab3INAQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 20:16:28 -0400
In-Reply-To: <87txhp249u.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 12 Sep 2013 13:06:53 -0700

> David, Eric, do any of you know why we have this netdevice notfier
> rebroadcast?

It's been there as long as I can remember, but I don't remember
exactly why we do that.

If I had to guess, it's to handle something that has to retry later
due to a "spin_trylock()" or similar type of situation.

Probably best to not remove it. :)
