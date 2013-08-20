From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: remember WOL preferences on driver load
Date: Tue, 20 Aug 2013 15:10:36 -0700 (PDT)
Message-ID: <20130820.151036.1067735437451172978.davem@davemloft.net>
References: <1376730002-9235-1-git-send-email-lekensteyn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	hayeswang@realtek.com, romieu@fr.zoreil.com
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab3HTWKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:10:37 -0400
In-Reply-To: <1376730002-9235-1-git-send-email-lekensteyn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>
Date: Sat, 17 Aug 2013 11:00:02 +0200

> From: Peter Wu <lekensteyn@gmail.com>
> 
> Do not clear Broadcast/Multicast/Unicast Wake Flag or LanWake in
> Config5. This is necessary to preserve WOL state when the driver is
> loaded. Although the r8168 vendor driver does not write Config5 (it has
> been commented out), Hayes Wang from Realtek said that masking bits like
> this is more sensible.
> 
> Signed-off-by: Peter Wu <lekensteyn@gmail.com>

Can I get some reviews and Ack's for this?

Thanks.
