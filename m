From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 10:47:08 +0200
Message-ID: <90885157901a546f5b79c9f33f0d21ff@localhost>
References: <1309849214.2720.45.camel@edumazet-laptop>
 <20110705.005011.1268380726966376331.davem@davemloft.net>
 <4E12C2B2.9060007@inliniac.net>
 <20110705.010254.1376215864913143868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <victor@inliniac.net>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:41790 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753949Ab1GEIrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 04:47:10 -0400
In-Reply-To: <20110705.010254.1376215864913143868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 05 Jul 2011 01:02:54 -0700 (PDT), David Miller wrote:



> Would you prefer to receive the frags individually?



I think both ways are favored. Often you just want to forward packets

unmodified after analysis, without any packet modification. For that the

packet should be received on the same socket (e.g. all with hash 0). On the

other hand there are use cases where packet analysis requires reassembled

packets.



Nice work David!



Hagen 
