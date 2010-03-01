From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: add accounting for socket backlog
Date: Sun, 28 Feb 2010 18:10:10 -0800 (PST)
Message-ID: <20100228.181010.211259500.davem@davemloft.net>
References: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
	<20100226.040536.247057194.davem@davemloft.net>
	<1267409328.23196.37.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38319
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753357Ab0CACJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 21:09:52 -0500
In-Reply-To: <1267409328.23196.37.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Mon, 01 Mar 2010 10:08:48 +0800

> Yeah, I only considered about the normal case, that is the TCP frames
> are built and managed in the kernel.

You're not even considering the kernel case completely.  It's just as
easy to modify the kernel to maliciously send frames in this way.

> If a user does frame generation himself, yes, the same problem could
> happen potentially for all protocols using backlog.

We need the protection for every protocol, please implement your
changes this way.

Thanks.
