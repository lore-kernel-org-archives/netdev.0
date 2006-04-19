From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC: 2.6 patch] net/netlink/: possible cleanups
Date: Wed, 19 Apr 2006 10:02:08 +1000
Message-ID: <44457E00.1030504@snapgear.com>
References: <20060413162710.GE4162@stusta.de> <20060413.132603.94193712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bne.snapgear.com ([203.143.235.140]:34825 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1750861AbWDSACL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 20:02:11 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060413.132603.94193712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2006 06:26 AM, David S. Miller wrote:
> These interfaces were added so that new users of netlink could
> write their code more easily.
>
> Unused does not equate to "comment out or delete".

Does a GENETLINK Kconfig option make sense (possibly dependant on
EMBEDDED)?  I'm unsure whether these interfaces are going to be used
in core networking code that can't be disabled anyway.
