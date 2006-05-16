From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: potential jiffy wrap bug in dev_watchdog
Date: Mon, 15 May 2006 22:12:20 -0700 (PDT)
Message-ID: <20060515.221220.12905232.davem@davemloft.net>
References: <20060515162858.35eee987@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21913
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751296AbWEPFMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 01:12:38 -0400
To: shemminger@osdl.org
In-Reply-To: <20060515162858.35eee987@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 15 May 2006 16:28:58 -0700

> There is a potential jiffy wraparound bug in the transmit watchdog
> that is easily avoided by using time_after().
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
