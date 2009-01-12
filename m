From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
	jiffies in htb_dequeue()
Date: Mon, 12 Jan 2009 11:08:57 +0000
Message-ID: <20090112110857.GB5901@ff.dom.local>
References: <20081210093532.GA7926@ff.dom.local> <20081216.155722.144236025.davem@davemloft.net> <20081217070303.GA4577@ff.dom.local> <20081216.233801.26557633.davem@davemloft.net> <496AE9A5.9060507@trash.net> <20090112101047.GA5448@ff.dom.local> <496B19F7.4060909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:38627 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbZALLJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 06:09:04 -0500
Received: by ug-out-1314.google.com with SMTP id 39so197635ugf.37
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 03:09:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <496B19F7.4060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 11:22:47AM +0100, Patrick McHardy wrote:
...
> It doesn't bother me :) I just think its the technical better
> and also most likely code-wise cleaner solution to this problem.
> Cancellation wouldn't be necessary since an unnecessary
> netif_schedule() doesn't really matter.

Hmm... Do you mean during destroying... It's probably not very long,
but deleting and creating qdiscs especially for some virtual devices
can take longer I guess.

Jarek P.
