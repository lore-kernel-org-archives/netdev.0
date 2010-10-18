From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: fix stats handling
Date: Mon, 18 Oct 2010 08:12:24 -0700 (PDT)
Message-ID: <20101018.081224.183035467.davem@davemloft.net>
References: <20101016032707.1925.10161.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	eric.dumazet@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40962
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755763Ab0JRPMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 11:12:01 -0400
In-Reply-To: <20101016032707.1925.10161.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 15 Oct 2010 20:27:10 -0700

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> There are currently some problems with igb.
> 
> - On 32bit arches, maintaining 64bit counters without proper
> synchronization between writers and readers.
> 
> - Stats updated every two seconds, as reported by Jesper.
>    (Jesper provided a patch for this)
> 
> - Potential problem between worker thread and ethtool -S
> 
> This patch uses u64_stats_sync, and convert everything to be 64bit safe,
> SMP safe, even on 32bit arches. It integrates Jesper idea of providing
> accurate stats at the time user reads them.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
