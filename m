From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: start hello_timer when enabling KERNEL_STP
 in br_stp_start
Date: Sun, 21 May 2017 13:34:16 -0400 (EDT)
Message-ID: <20170521.133416.722357246427267240.davem@davemloft.net>
References: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com, cera@cera.cz
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbdEUReS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:34:18 -0400
In-Reply-To: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 19 May 2017 22:20:29 +0800

> Since commit 76b91c32dd86 ("bridge: stp: when using userspace stp stop
> kernel hello and hold timers"), bridge would not start hello_timer if
> stp_enabled is not KERNEL_STP when br_dev_open.
> 
> The problem is even if users set stp_enabled with KERNEL_STP later,
> the timer will still not be started. It causes that KERNEL_STP can
> not really work. Users have to re-ifup the bridge to avoid this.
> 
> This patch is to fix it by starting br->hello_timer when enabling
> KERNEL_STP in br_stp_start.
> 
> As an improvement, it's also to start hello_timer again only when
> br->stp_enabled is KERNEL_STP in br_hello_timer_expired, there is
> no reason to start the timer again when it's NO_STP.
> 
> Fixes: 76b91c32dd86 ("bridge: stp: when using userspace stp stop kernel hello and hold timers")
> Reported-by: Haidong Li <haili@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
