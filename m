From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] pkt_sched: Control group classifier
Date: Thu, 16 Oct 2008 07:41:55 +0200
Message-ID: <873aixksf0.fsf@basil.nowhere.org>
References: <20081013155715.GZ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46784 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbYJPFl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 01:41:59 -0400
In-Reply-To: <20081013155715.GZ20815@postel.suug.ch> (Thomas Graf's message of "Mon, 13 Oct 2008 17:57:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> writes:
>
> The principle of the classifier is to directly access the
> task_struct via get_current(). In order for this to work,
> classification requests from softirqs must be ignored.

You mean the classifier just wants to know if it runs
as a softirq?

> This is
> not a problem because the vast majority of packets in softirq
> context are not assigned to a task anyway. For this to work, a
> mechanism is needed to trace softirq context.
> The only existing
> way to do so is to use the TRACE_IRQFLAGS feature, unfortunately

Does't softirq_count() > 0 check that?

-Andi

-- 
ak@linux.intel.com
