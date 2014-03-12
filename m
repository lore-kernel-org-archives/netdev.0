From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next 2014-03-10
Date: Tue, 11 Mar 2014 23:47:12 -0400 (EDT)
Message-ID: <20140311.234712.259725858772258155.davem@davemloft.net>
References: <20140310190101.GB25703@tuxdriver.com>
	<20140311.225023.1953610775705849306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754145AbaCLDrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 23:47:14 -0400
In-Reply-To: <20140311.225023.1953610775705849306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 11 Mar 2014 22:50:23 -0400 (EDT)

> Pulled, thanks a lot John.

Actually, I have to fix something up.

Regardless of whatever the situation is, reverting the build fix
to drivers/staging/rtl8821ae/rc.c is not correct.

I do not see what the big deal is.  If the wireless tree makes
a change to a structure, it absolutely is correct to keep the
wireless staging drivers working, and above all _building_
when such a change is made.

So the staging tree might have to do a merge of some sort, big deal.

I'm reverting the revert in my merge commit.

Please do not introduce build errors like this in the future,
thank you.
