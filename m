From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug: alx: Atheros AR8131/AR8151/AR8152/AR8161 Ethernet driver
Date: Tue, 06 Aug 2013 05:07:01 -0700
Message-ID: <1375790821.4457.90.camel@edumazet-glaptop>
References: <CACtZaFJZCWigdT6_vsP9BTRSORzumu33xUtyPtpiDuNn3DQi+w@mail.gmail.com>
	 <20130805225752.14e843f7@nehalam.linuxnetplumber.net>
	 <CACtZaF+nTHiZ03uebya92b=UVLBXAk9jnM-=Pp3GQ6oSNv8ndA@mail.gmail.com>
	 <1375785799.4457.81.camel@edumazet-glaptop>
	 (sfid-20130806_124324_003243_F85A36DB) <1375788758.8219.13.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kinley Dorji <kinleyd@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:52900 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756083Ab3HFMHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 08:07:03 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so632427pab.7
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 05:07:03 -0700 (PDT)
In-Reply-To: <1375788758.8219.13.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 13:32 +0200, Johannes Berg wrote:

> I don't. There are some stats in the original code at
> https://github.com/erikarn/alx, but I removed them because I didn't
> really understand what was going on and don't really care much for the
> stats in the system I'm using this device on - and based on the driver
> I'm not sure I'd use the chip for 'serious' work anyway :)
> 

OK, their code seems clean and should be copied/pasted.


> FWIW, it had ndo_get_stats() but was updating the netdev->stats from
> that handler and then returning them, which seemed a bit questionable.
> 

Its fine, as updates of each field are atomic (unsigned long)
