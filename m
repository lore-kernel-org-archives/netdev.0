From: David Miller <davem@davemloft.net>
Subject: Re: [patch 08/16] atm: idt77105: Use del_timer_sync() in exit path
Date: Tue, 25 Mar 2014 21:06:30 -0400 (EDT)
Message-ID: <20140325.210630.2082315424643101163.davem@davemloft.net>
References: <20140323150557.288925975@linutronix.de>
	<20140323150753.433572795@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	akpm@linux-foundation.org, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603AbaCZBGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 21:06:32 -0400
In-Reply-To: <20140323150753.433572795@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Sun, 23 Mar 2014 15:09:28 -0000

> The module is about to go away. Make sure everything is stopped safely
> before we pull the plug.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Applied.
