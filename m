From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: tg3: fix brace, switch, and comma spacing coding
 style in tg3.c This is a patch to the tg3.c file that aligns switch and
 case statements, else statements following braces, and inserts a space
 after commas listed in the coding style guidelines and verified by
 checkpatch.pl tool.
Date: Sat, 13 Mar 2010 11:49:39 -0800 (PST)
Message-ID: <20100313.114939.120459447.davem@davemloft.net>
References: <1268509151-27281-1-git-send-email-sharms@ubuntu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, benli@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sharms@ubuntu.com
To: sjharms@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44379
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935639Ab0CMTtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 14:49:17 -0500
In-Reply-To: <1268509151-27281-1-git-send-email-sharms@ubuntu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Harms <sjharms@gmail.com>
Date: Sat, 13 Mar 2010 14:39:11 -0500

> -#define tw32_mailbox(reg, val)	tp->write32_mbox(tp, reg, val)
> -#define tw32_mailbox_f(reg, val)	tw32_mailbox_flush(tp, (reg), (val))
> -#define tw32_rx_mbox(reg, val)	tp->write32_rx_mbox(tp, reg, val)
> -#define tw32_tx_mbox(reg, val)	tp->write32_tx_mbox(tp, reg, val)
> -#define tr32_mailbox(reg)	tp->read32_mbox(tp, reg)
> +#define tw32_mailbox(reg, val)	(tp->write32_mbox(tp, reg, val))

Please keep this kind of code masterbation to yourself.
This is not the style we want for this driver.
