From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Tue, 06 Aug 2013 13:32:38 +0200
Message-ID: <1375788758.8219.13.camel@jlt4.sipsolutions.net>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
	 <20130805225752.14e843f7@nehalam.linuxnetplumber.net>
	 <CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com>
	 <1375785799.4457.81.camel@edumazet-glaptop>
	 (sfid-20130806_124324_003243_F85A36DB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kinley Dorji <kinleyd@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:54897 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755922Ab3HFLcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 07:32:43 -0400
In-Reply-To: <1375785799.4457.81.camel@edumazet-glaptop> (sfid-20130806_124324_003243_F85A36DB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 03:43 -0700, Eric Dumazet wrote:

> > $ ethtool -S eth0
> > no stats available
> 
> It seems alx driver does not support stats.
> 
> (No ndo_get_stats() and no changes on netdev->stats embedded stats)
> 
> 
> drivers/net/ethernet/atheros/atl1c/atl1c_main.c provides
> atl1c_get_stats() gathering hardware counters
> 
> CC Johannes Berg, let see if he has plan to add them on alx

I don't. There are some stats in the original code at
https://github.com/erikarn/alx, but I removed them because I didn't
really understand what was going on and don't really care much for the
stats in the system I'm using this device on - and based on the driver
I'm not sure I'd use the chip for 'serious' work anyway :)

FWIW, it had ndo_get_stats() but was updating the netdev->stats from
that handler and then returning them, which seemed a bit questionable.

johannes
