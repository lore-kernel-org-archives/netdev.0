From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/7] bonding: get rid of curr_slave_lock
Date: Sat, 13 Sep 2014 16:30:17 -0400 (EDT)
Message-ID: <20140913.163017.945514192048510396.davem@davemloft.net>
References: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@gmail.com, j.vosburgh@gmail.com,
	andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbaIMUaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:30:20 -0400
In-Reply-To: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 11 Sep 2014 22:49:21 +0200

> This is the second patch-set dealing with bond locking and the purpose here
> is to convert curr_slave_lock into a spinlock called "mode_lock" which can
> be used in the various modes for their specific needs. The first three
> patches cleanup the use of curr_slave_lock and prepare it for the
> conversion which is done in patch 4 and then the modes that were using
> their own locks are converted to use the new "mode_lock" giving us the
> opportunity to remove their locks.
> This patch-set has been tested in each mode by running enslave/release of
> slaves in parallel with traffic transmission and miimon=1 i.e. running
> all the time. In fact this lead to the discovery of a subtle bug related to
> RCU which will be fixed in -net.
> Also did an allmodconfig test just in case :-)

:-)

> v2: fix bond_3ad_state_machine_handler's use of mode_lock and
>     curr_slave_lock

Series applied, thanks.
