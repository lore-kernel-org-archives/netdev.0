From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Intel-wired-lan] [e1000_netpoll] BUG: sleeping function called
 from invalid context at kernel/irq/manage.c:110
Date: Fri, 29 Jul 2016 01:28:44 +0200
Message-ID: <20160728232844.GA25372@electric-eye.fr.zoreil.com>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com>
 <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <1469655487.2232.49.camel@intel.com>
 <1469684635.9389.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ye Xiaolong <xiaolong.ye@intel.com>,
	intel-wired-lan@lists.osuosl.org,
	Satyam Sharma <satyam@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46341 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbcG1X3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 19:29:24 -0400
Content-Disposition: inline
In-Reply-To: <1469684635.9389.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> I would prefer having a definitive advice from Thomas Gleixner and/or
> others if disable_irq() is forbidden from IRQ path.
> 
> As I said, about all netpoll() methods in net drivers use disable_irq()
> so a lot of patches would be needed.

s/about all/many/

There has been a WARN_ONCE(!irqs_disabled() in netpoll_send_skb_on_dev for
quite some time now but it's apparently screened by too many tests to be
effective. :o/

-- 
Ueimor
