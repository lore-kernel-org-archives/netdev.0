From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen patch available for perusal.
Date: Fri, 3 Nov 2006 21:24:39 +0100
Message-ID: <17739.42375.80475.907057@robur.slu.se>
References: <45468F2E.4060809@candelatech.com>
	<17736.54766.657083.873206@robur.slu.se>
	<4548F166.1020001@candelatech.com>
	<17739.9326.620495.394705@robur.slu.se>
	<454B6F9D.8030300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:57248 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S932083AbWKCUYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 15:24:43 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <454B6F9D.8030300@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ben Greear writes:

 > It requires a hook in dev.c, or at least that is the only way I can 
 > think to implement it.

Well the hook be placed along the packet path even in drivers. In tulip I didn't 
even take packet of the ring in some experiments. 

And there plenty of existing hooks already i.e PRE_ROUTE?

 > I don't think that hook is going to be allowed into the kernel, so the 
 > best I was hoping for  was to have the code in pktgen with #if 0 and let 
 > users patch their kernel to add the hook...

Right so what I was trying to say was rather having #if 0 and dead code in 
pktgen it could be kept separate. 

Cheers.
						--ro

