From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SiS190/191 half-duplex initialization fix
Date: Tue, 16 Feb 2010 14:47:56 -0800 (PST)
Message-ID: <20100216.144756.71882700.davem@davemloft.net>
References: <1266265140-20196-1-git-send-email-birrachiara@tin.it>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: birrachiara@tin.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933148Ab0BPWrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 17:47:41 -0500
In-Reply-To: <1266265140-20196-1-git-send-email-birrachiara@tin.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Riccardo Ghetta <birrachiara@tin.it>
Date: Mon, 15 Feb 2010 21:19:00 +0100

> +        u32 negotiated_lpa;

Uses spaces instead of tabs.

> + 		tp->negotiated_lpa = p->val;

Has a space then tabs, should be all tab characters.

> +	if (tp->negotiated_lpa & (LPA_1000HALF | LPA_100HALF | LPA_10HALF))
> +	{

Should be:

	if (condition) {

ie. the openning brace need to be on the same line as the if
statement.

Please fix these issues up and resubmit your patch, thanks.
