From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Tracepoints for queueing skb to rcvbuf
Date: Tue, 21 Jun 2011 16:07:10 -0700 (PDT)
Message-ID: <20110621.160710.1393299068066105811.davem@davemloft.net>
References: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com,
	dle-develop@lists.sourceforge.net, seiji.aguchi@hds.com
To: satoru.moriya@hds.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757165Ab1FUXI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 19:08:27 -0400
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C402B96E4@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satoru Moriya <satoru.moriya@hds.com>
Date: Fri, 17 Jun 2011 17:56:55 -0400

> To separate these reasons, this patchset adds 3 tracepoints.
> 
> 1st one is added to __udp_queue_rcv_skb to get return value of
> ip_queue_rcv_skb. Analyzing it we can separate above (*) (3 possibilities).
> 
> 2nd and 3rd one are to get more detailed information. We can collect status 
> of socket receive queue and related parameters(some of them are sysctl knob
> e.g. /proc/sys/net/ipv4/udp_mem, etc. for UDP) and then we can tune kernel
> behavior easily.

Both patches applied, thanks.
