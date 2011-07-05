From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 09:52:18 +0200
Message-ID: <4E12C2B2.9060007@inliniac.net>
References: <1309846875.2720.43.camel@edumazet-laptop> <4E12B5A6.2020802@inliniac.net> <1309849214.2720.45.camel@edumazet-laptop> <20110705.005011.1268380726966376331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:57304 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183Ab1GEHwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 03:52:43 -0400
In-Reply-To: <20110705.005011.1268380726966376331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 09:50 AM, David Miller wrote:
> I will add an option to the fanout, as a flag bit to the setsockopt,
> that will cause the fanout to act as a ip_defrag() agent and rehash
> the packet once all the fragments arrive.
> 
> Since this will operate internally on the clones passed to AF_PACKET,
> it will not have any effect on the original packets traversing through
> the machine.
> 

Does this mean the user space app gets a reassembled packet from the fan
out?

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

