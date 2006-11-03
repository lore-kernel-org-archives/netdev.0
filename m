From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen patch available for perusal.
Date: Fri, 3 Nov 2006 12:13:50 +0100
Message-ID: <17739.9326.620495.394705@robur.slu.se>
References: <45468F2E.4060809@candelatech.com>
	<17736.54766.657083.873206@robur.slu.se>
	<4548F166.1020001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:13445 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1753222AbWKCLN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 06:13:59 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4548F166.1020001@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ben Greear writes:

 > I'd be thrilled to have the receive logic go into pktgen, even if it was #if 0 with a comment
 > showing how to patch dev.c to get it working.  It would make my out-of-tree patch smaller
 > and should help others who are doing research and driver development...


 Just an idea... RX part is pretty separate from TX. How about if we keep the 
 this code in a small seprate optional module? It can developed into some general 
 RX probe.

 Cheers.
						--ro
