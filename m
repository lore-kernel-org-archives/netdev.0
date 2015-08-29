From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] bonding: fix bond_poll_controller bh_enable
 warning
Date: Fri, 28 Aug 2015 22:26:45 -0700 (PDT)
Message-ID: <20150828.222645.1574109168572497876.davem@davemloft.net>
References: <69380EC5-CF63-48BE-AFCB-4F70E6869DFC@cumulusnetworks.com>
	<1440799532-9150-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 13806511171@163.com,
	shemminger@linux-foundation.org, maheshb@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbbH2F0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:26:46 -0400
In-Reply-To: <1440799532-9150-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 28 Aug 2015 15:05:32 -0700

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> The problem is rcu_read_unlock_bh() which triggers a warning when irqs are
> disabled. ndo_poll_controller should run with irqs disabled always so we
> can drop the rcu_read_lock_bh.
 ...
> Fixes: 616f45416ca0 ("bonding: implement bond_poll_controller()")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v3: After Dave made it clear that poll_controller should always be called
> with interrupts disabled we can simply drop the rcu bh lock.

Applied.
