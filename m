From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] pkt_sched: Control group classifier
Date: Fri, 07 Nov 2008 22:56:08 -0800 (PST)
Message-ID: <20081107.225608.01221973.davem@davemloft.net>
References: <20081106161330.GN20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752394AbYKHG4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Nov 2008 01:56:09 -0500
In-Reply-To: <20081106161330.GN20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 6 Nov 2008 17:13:30 +0100

> The classifier should cover the most common use case and will work
> without any special configuration.
> 
> The principle of the classifier is to directly access the
> task_struct via get_current(). In order for this to work,
> classification requests from softirqs must be ignored. This is
> not a problem because the vast majority of packets in softirq
> context are not assigned to a task anyway. For this to work, a
> mechanism is needed to trace softirq context. 
> 
> This repost goes back to the method of relying on the number of
> nested bh disable calls for the sake of not adding too much
> complexity and the option to come up with something more reliable
> if actually needed.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
