From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] icplus: mdio_write(), remove unnecessary for loop
Date: Thu, 1 Dec 2011 19:53:29 +0100
Message-ID: <20111201185329.GA23475@electric-eye.fr.zoreil.com>
References: <1322746016-2835-1-git-send-email-patrick.kelle81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sorbica@icplus.com.tw
To: Patrick Kelle <patrick.kelle81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47861 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755789Ab1LATAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 14:00:04 -0500
Content-Disposition: inline
In-Reply-To: <1322746016-2835-1-git-send-email-patrick.kelle81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Kelle <patrick.kelle81@gmail.com> :
[...]
> As suggested by David Miller:
> "You can simply this even further since p[7] is what is used here,
> and this means len is one, the inner loop therefore executes only
> once, and the p[7].field value is not used (it's zero in the table)
> and the write to it is completely thrown away."

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

However you can:
- shorten p[] as p[7] is never used
- use read_phy_bit() to avoid the last three lines
- ARRAY_SIZE(p) the first loop (so the first limit - 7 - appears)

-- 
Ueimor
