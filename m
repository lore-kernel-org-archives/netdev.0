From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] icplus: mdio_write(), remove unnecessary for loop
Date: Thu, 01 Dec 2011 12:55:04 -0500 (EST)
Message-ID: <20111201.125504.1641339242050833778.davem@davemloft.net>
References: <1322746016-2835-1-git-send-email-patrick.kelle81@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, sorbica@icplus.com.tw
To: patrick.kelle81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787Ab1LAR4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 12:56:16 -0500
In-Reply-To: <1322746016-2835-1-git-send-email-patrick.kelle81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Kelle <patrick.kelle81@gmail.com>
Date: Thu,  1 Dec 2011 14:26:56 +0100

> At this point the variable j is always set to 7 and the code within
> the loop has to run only once anyway.
> 
> As suggested by David Miller:
> "You can simply this even further since p[7] is what is used here,
> and this means len is one, the inner loop therefore executes only
> once, and the p[7].field value is not used (it's zero in the table)
> and the write to it is completely thrown away."
> 
> Signed-off-by: Patrick Kelle <patrick.kelle81@gmail.com>

Applied.
