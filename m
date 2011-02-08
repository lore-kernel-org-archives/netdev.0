From: David Miller <davem@davemloft.net>
Subject: Re: Trouble Shooting ipsec
Date: Tue, 08 Feb 2011 11:37:08 -0800 (PST)
Message-ID: <20110208.113708.226773767.davem@davemloft.net>
References: <4D504563.5010802@earthlink.net>
	<20110208183527.GA7450@hmsreliant.think-freely.org>
	<4D519A7D.5010405@earthlink.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45533
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755557Ab1BHTgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 14:36:32 -0500
In-Reply-To: <4D519A7D.5010405@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Clark <sclark46@earthlink.net>
Date: Tue, 08 Feb 2011 14:33:17 -0500

> I'll continue investigating. It just so frustrating when the ipsec
> packets just get dropped and you have no idea why. I wish there were
> some hooks in the kernel so you could at least get some debug
> information about what is happening.

There is a tracepoint (which you can monitor using perf) which tracks
all packet drops.
