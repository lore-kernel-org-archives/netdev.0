From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] MTU changes and other fixes
Date: Thu, 07 Jan 2016 16:33:14 -0500 (EST)
Message-ID: <20160107.163314.666536912327323086.davem@davemloft.net>
References: <1451995051-21920-1-git-send-email-jakub.kicinski@netronome.com>
	<20160107.145750.213741381921685070.davem@davemloft.net>
	<20160107204928.0cd91c16@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbcAGVdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 16:33:17 -0500
In-Reply-To: <20160107204928.0cd91c16@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 7 Jan 2016 20:49:28 +0000

> I know this is not what you asked for but, since we are using FW
> commands to disable/enable RX, even if we allocate all required
> resources before freeing old ones we still cannot guarantee that
> the reenabling operation will not fail.  Should we refuse to do
> MTU changes while the interface is running altogether?

If you issue the MTU change command and it fails, then you're still
configured at the old MTU.  There should therefore be no problem
rewinding in that case.

> All drivers I've seen ...

Bad practice in other drivers should be ignored, not copied.
