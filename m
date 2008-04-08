From: David Miller <davem@davemloft.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Tue, 08 Apr 2008 14:16:12 -0700 (PDT)
Message-ID: <20080408.141612.55862960.davem@davemloft.net>
References: <1203969502.19319.279.camel@localhost>
	<47FBD30A.1010003@trash.net>
	<1207688549.1020.90.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36005
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752561AbYDHVQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 17:16:11 -0400
In-Reply-To: <1207688549.1020.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 08 Apr 2008 14:02:29 -0700

> I think that the changes to pr_debug, dev_dbg, and dev_vdbg
> to use an "if (0) printk" macro rather than an empty inline
> I posted a few times without any reply or comment should work
> for most all cases.

Joe, fix this directly like we did for VLAN, by changing
these spots away from print_mac().

We can do work on this other idea of yours independantly.
All you do by bringing it up is distract things and defer
the fix even further.

You've already wasted more than a month not fixing this
like you said you would, and you added this regression
so it is your responsibility to fix this in a timerly
manner.

Please remove print_mac() usage from these spots in the
code as requested by Patrick.

Thank you.
