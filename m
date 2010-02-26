From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: sock_aio_write: set CMSG_MSG_COMPAT flag if
 is_compat_task
Date: Fri, 26 Feb 2010 02:06:33 -0800 (PST)
Message-ID: <20100226.020633.240678771.davem@davemloft.net>
References: <1266583307-3049-6-git-send-email-fwestphal@astaro.com>
	<20100226.011646.257642830.davem@davemloft.net>
	<20100226100305.GA16504@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43780
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751711Ab0BZKGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:06:15 -0500
In-Reply-To: <20100226100305.GA16504@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 26 Feb 2010 11:03:05 +0100

> If its necessary to set MSG_CMSG_COMPAT properly for plain
> write() as well to have the patch set merged then
> I'll see about adding such a ->compat_write and will resubmit
> the entire set again once net-next opens again for 2.6.35.

If you can get the VFS folks to take the addition of the
->compat_write hook quickly, I can still merge your patch series for
2.6.34
