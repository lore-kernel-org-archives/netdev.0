From: David Miller <davem@davemloft.net>
Subject: Re: [NOT VERY SAFE] [TCP]: Set initial_ssthresh default to zero in
 Cubic and BIC.
Date: Sat, 13 Oct 2007 15:52:11 -0700 (PDT)
Message-ID: <20071013.155211.92587020.davem@davemloft.net>
References: <20071006132601.f944f461.komurojun@nifty.com>
	<20071014073658.d4352b8c.komurojun@nifty.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@sunset.davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: komurojun@nifty.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753270AbXJMWwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 18:52:10 -0400
In-Reply-To: <20071014073658.d4352b8c.komurojun@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Komuro <komurojun@nifty.com>
Date: Sun, 14 Oct 2007 07:36:58 +0900

> 
> Dear David
> 
> The patch "[TCP]: Set initial_ssthresh default to zero in Cubic and BIC."
> is not very safe.
> 
> With this patch, ftp-transfer stops in my system.
> (vsftpd-2.0.5-8)
> 
> Please revert this patch.

No, I will not revert it with so little information, that would be a
knee-jerk reaction.

Let's anaylyze the problem first.  Please:

1) Send this report to the correct place, which is netdev@vger.kernel.org,
   so that the networking developers can analyze the bug.  Most of
   the core networking developers do not read linux-kernel so they
   did not see your report.

2) Provide a test case that the developers can use the precisely
   reproduce the problem.  Your problem may be dependant upon the
   remote system or infrastructure such as firewalls that sit between
   your machine and the remote one, so it may instead be useful
   to provide a tcpdump of the failing transfer.

I suspect some intermediate node, such as a firewall, is corrupting
your connection and causing the transfer to fail, and thus reverting
the BIC/CUBIC patch is just a workaround.

There are no other reports like your's and that change has been in
the tree for long enough to get substantial exposure.
