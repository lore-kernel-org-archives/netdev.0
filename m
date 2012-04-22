From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] l2tp: misc fixes and add L2TPv3 IP encap over
 IPv6
Date: Sun, 22 Apr 2012 00:29:33 -0400 (EDT)
Message-ID: <20120422.002933.177233922611577116.davem@davemloft.net>
References: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab2DVE3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 00:29:41 -0400
In-Reply-To: <1334912573-28804-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Fri, 20 Apr 2012 10:02:43 +0100

> This patch series includes several L2TP fixes / cleanups and adds
> L2TPv3 IP encapsulation support for IPv6.
> 
> Patches 4-10 depend on Benjamin LaHaise's L2TP UDP IPv6 patches which
> have already been submitted for review. Patches 1-3 are not IPv6
> related so can be reviewed / applied now.

They aren't in review state, they're in "changed requested" state
because they are obviously broken and need changes since you hit
all of those checksum problems on loopback when you tested it.

Never submit patch sets against another patch series that is going
to have to go through changes before it goes into the tree.

I'm dropping this entire set, resubmit after Ben fixes the checksum
problems and does a new submission.
