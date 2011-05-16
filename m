From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] output ipconfig info message as one printk
Date: Mon, 16 May 2011 14:00:35 -0400 (EDT)
Message-ID: <20110516.140035.72516501072074389.davem@davemloft.net>
References: <1305409519-25404-1-git-send-email-micha@neli.hopto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: micha@neli.hopto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633Ab1EPSAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 14:00:39 -0400
In-Reply-To: <1305409519-25404-1-git-send-email-micha@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Micha Nelissen <micha@neli.hopto.org>
Date: Sat, 14 May 2011 23:45:19 +0200

> the "ip-config complete" message with ip address etc is output using
> many printks. When using the netconsole, and multiple agents are booting
> (and logging their boot) simultaneously, the syslog of the receiving
> host gets very messy, as the individual printks are interleaved.
> Combining the many printks into one printk improves syslog readability.

First, you are missing a proper "Signed-off-by: " tag in your
patch submissions.

Second, you should not do this because now the lines after the
first won't have the default loglevel prepended.

I think this should just be left alone, and you should properly
mark your netconsole logs so that you can discern which machine
the individual messages come from so you can piece them together
properly if you need to.
