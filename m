From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen patch available for perusal.
Date: Mon, 6 Nov 2006 15:14:56 +0100
Message-ID: <17743.17248.185895.461854@robur.slu.se>
References: <45468F2E.4060809@candelatech.com>
	<17736.54766.657083.873206@robur.slu.se>
	<4548F166.1020001@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:49077 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1753201AbWKFOO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 09:14:59 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4548F166.1020001@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ben Greear writes:
 > > Changes:
 > > * use a nano-second timer based on the scheduler timer (TSC) for relative times, instead of get_time_of_day.

Seems I missed to set tsc as clocksource. It makes a difference. Performance is 
normal and I'm less confused.

e1000 82546GB @ 1.6 GHz Opteron. Kernel 2.6.19-rc1_Bifrost_-g18e199c6-dirty 

echo acpi_pm    > /sys/devices/system/clocksource/clocksource0/current_clocksource   

psize pps
---------
60  556333
124  526942
252  452981
508  234996
1020  119748
1496  82248

echo tsc        > /sys/devices/system/clocksource/clocksource0/current_clocksource 

psize pps
---------
60  819914
124  747286
252  452975
508  234993
1020  119749
1496  82247

Cheers.	
						--ro
