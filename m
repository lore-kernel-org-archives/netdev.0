From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 24842] New: Compatibility issue with uggly Windows
 RFC1323 implementation.
Date: Thu, 16 Dec 2010 14:08:51 -0800 (PST)
Message-ID: <20101216.140851.15238748.davem@davemloft.net>
References: <1292260479.2759.69.camel@edumazet-laptop>
	<AANLkTikTgbKSNYHthic8P3bi9+ewN8fEBknnSK=tdTgU@mail.gmail.com>
	<1292279462.2679.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitriy.balakin@nicneiron.ru, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45308
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757361Ab0LPWIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:08:23 -0500
In-Reply-To: <1292279462.2679.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Dec 2010 23:31:02 +0100

> [PATCH net-next-2.6] tcp: relax tcp_paws_check()
> 
> Some windows versions have wrong RFC1323 implementations, with SYN and
> SYNACKS messages containing zero tcp timestamps.
> 
> We relaxed in commit fc1ad92dfc4e363 the passive connection case
> (Windows connects to a linux machine), but the reverse case (linux
> connects to a Windows machine) has an analogue problem when tsvals from
> windows machine are 'negative' (high order bit set) : PAWS triggers and
> we drops incoming messages.
> 
> Fix this by making zero ts_recent value special, allowing frame to be
> processed.
> 
> Based on a report and initial patch from Dmitiy Balakin
> 
> Bugzilla reference : https://bugzilla.kernel.org/show_bug.cgi?id=24842
> 
> Reported-by: dmitriy.balakin@nicneiron.ru
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks!
