From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sat, 17 Jan 2009 19:40:45 -0600
Message-ID: <20090117194045.649f55a0@osprey.hogchain.net>
References: <gkt97e$ti0$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Sitsofe Wheeler <sitsofe@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:29408 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420AbZARBku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 20:40:50 -0500
In-Reply-To: <gkt97e$ti0$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Modifying subject line and cc'ing netdev]

On Sat, 17 Jan 2009 18:49:18 +0000 (UTC)
Sitsofe Wheeler <sitsofe@yahoo.com> wrote:

> On an ever so slightly modified 2.6.28. I think this only happens
> when the upstream router/switch goes out to lunch and packets are
> being sent. It is reproducible but only appears on a home network...
> 
> [  204.704065] ------------[ cut here ]------------
> [  204.704074] WARNING: at net/sched/sch_generic.c:226 dev_watchdog
> +0x22b/0x240()
> [  204.704080] NETDEV WATCHDOG: eth0 (atl2): transmit timed out

Please provide your complete dmesg output.

What do you do to reproduce this?

Can you briefly describe the device immediately upstream of the system producing
the warning?

Thanks,
Jay
