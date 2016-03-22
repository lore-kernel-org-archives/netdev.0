From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2] ipv4: fix broadcast packets reception
Date: Tue, 22 Mar 2016 15:54:26 -0400 (EDT)
Message-ID: <20160322.155426.562303496878634271.davem@redhat.com>
References: <c8ad97bbb6f1c9ec8c523209c1203d1982faab6f.1458634653.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	sbohrer@rgmadvisors.com, hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbcCVTyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 15:54:32 -0400
In-Reply-To: <c8ad97bbb6f1c9ec8c523209c1203d1982faab6f.1458634653.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 22 Mar 2016 09:19:38 +0100

> Currently, ingress ipv4 broadcast datagrams are dropped since,
> in udp_v4_early_demux(), ip_check_mc_rcu() is invoked even on
> bcast packets.
> 
> This patch addresses the issue, invoking ip_check_mc_rcu()
> only for mcast packets.
> 
> Fixes: 6e5403093261 ("ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> 
> --
>  v1 -> v2 droped the route related bits, the fib_validate_source()
>   failures are triggered by the in_device configuration

Applied and queued up for -stable, thanks.
