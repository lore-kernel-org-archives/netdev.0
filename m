From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] syncookies: add support for ECN
Date: Sat, 26 Jun 2010 22:00:55 -0700 (PDT)
Message-ID: <20100626.220055.216746824.davem@davemloft.net>
References: <1277156925-7295-1-git-send-email-fw@strlen.de>
	<1277156925-7295-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750948Ab0F0FAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 01:00:43 -0400
In-Reply-To: <1277156925-7295-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 21 Jun 2010 23:48:45 +0200

> Allows use of ECN when syncookies are in effect by encoding ecn_ok
> into the syn-ack tcp timestamp.
> 
> While at it, remove a uneeded #ifdef CONFIG_SYN_COOKIES.
> With CONFIG_SYN_COOKIES=nm want_cookie is ifdef'd to 0 and gcc
> removes the "if (0)".
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Also applied, nice work Florian.
