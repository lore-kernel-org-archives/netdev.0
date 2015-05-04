From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: run ingress qdisc without locks
Date: Sun, 03 May 2015 23:42:29 -0400 (EDT)
Message-ID: <20150503.234229.1652771210116002653.davem@davemloft.net>
References: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, jhs@mojatatu.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbbEDDmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 23:42:31 -0400
In-Reply-To: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Thu, 30 Apr 2015 20:14:07 -0700

> TC classifiers/actions were converted to RCU by John in the series:
> http://thread.gmane.org/gmane.linux.network/329739/focus=329739
> and many follow on patches.
> This is the last patch from that series that finally drops
> ingress spin_lock.
> 
> Single cpu ingress+u32 performance goes from 22.9 Mpps to 24.5 Mpps.
> 
> In two cpu case when both cores are receiving traffic on the same
> device and go into the same ingress+u32 the performance jumps
> from 4.5 + 4.5 Mpps to 23.5 + 23.5 Mpps
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks.
