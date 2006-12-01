From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen
Date: Fri, 1 Dec 2006 18:18:02 +0100
Message-ID: <17776.25546.260105.848354@robur.slu.se>
References: <b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com>
	<17774.39482.949953.625608@robur.slu.se>
	<456F15F7.3000700@candelatech.com>
	<20061130.201423.118625277.davem@davemloft.net>
	<17775.58441.678623.396102@robur.slu.se>
	<b6fcc0a0612010151s4231cae6n9252f8816406e1d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Robert Olsson" <Robert.Olsson@data.slu.se>,
	"David Miller" <davem@davemloft.net>, greearb@candelatech.com,
	pavol.gono@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:21417 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1031648AbWLARSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 12:18:31 -0500
To: "Alexey Dobriyan" <adobriyan@gmail.com>
In-Reply-To: <b6fcc0a0612010151s4231cae6n9252f8816406e1d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Alexey Dobriyan writes:

 > 
 > Confused now. Is my "t->control &= ~(T_TERMINATE);" fix deprecated by
 > completions?
 
 It's not needed with completion patch as this does the job a bit more
 mainstream. The T_TERMINATE seems to work well I've tested on machine
 with CPU:s. Only once I noticed that only 2 of 4 threads got started 
 but it could be something else...

 And the race is hardly seen with any real use of pktgen.. .Let's hear
 what others... and completions was out-of-date.

 Cheers.
					--ro
 
