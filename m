From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_tree_lock in cbq_put, hfsc_put_class
	and htb_put
Date: Mon, 4 Feb 2008 11:57:29 +0000
Message-ID: <20080204115729.GB6598@ff.dom.local>
References: <20080203145234.GA3170@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	jamal <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:34915 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbYBDLu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 06:50:26 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1133945ugc.16
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2008 03:50:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080203145234.GA3170@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch is wrong - don't apply, please!

Sorry,
Jarek P.

On 03-02-2008 15:52, Jarek Poplawski wrote:
> [NET_SCHED] sch_tree_lock in cbq_put, hfsc_put_class and htb_put
> 
> Qdisc_class_ops ->put() "methods" call xxx_destroy_class() functions
> without sch_tree_lock(), which is needed at least for qdisc_destroy()
> of a subqueue, but also for deactivating and list/rb_tree updates in
> case of HTB. (Since errors caused by such a bug could be very hard to
> reproduce the effectiveness of this patch wasn't confirmed by tests,
> but IMHO the need of this lock is quite obvious here.)
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
...
