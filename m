From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 00/10 net-next] Introduce per interface ipv4 statistics
Date: Fri, 16 Dec 2011 10:55:18 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1112161053030.26765@router.home>
References: <igorm@etf.rs> <1324049163-11207-1-git-send-email-igorm@etf.rs>   <1324050080.25554.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <CAFdo_mWY3030_WsL_awXFMaviMA5MGJP_gMs0cM=6KeGQft6-Q@mail.gmail.com>  <1324053184.25554.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
  <alpine.DEB.2.00.1112161043080.26765@router.home> <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: igorm@etf.rs, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.prem.mail.ac4.yahoo.com ([76.13.13.44]:47403 "HELO
	smtp105.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752189Ab1LPQzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 11:55:20 -0500
In-Reply-To: <1324054244.25554.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Dec 2011, Eric Dumazet wrote:

> Or we could use a hierarchical split : Say 16 (or 32 or 64) cpus share
> same counters (must be atomic if NR_CPUS > 16/32/64)

Then you'd need to have locking or full atomic operations for the
counters. Reduction of network processing to a set of processors also will
have other beneficial effects in addition to cache hotness. It would
removing OS jitter etc etc.

> percpu_alloc() -> percpugroup_alloc()

Sounds like a per cpuset/cgroup allocation?
