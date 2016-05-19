From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH] net: phy: Ensure the state machine is called when phy is
 UP
Date: Thu, 19 May 2016 18:31:47 +0200
Message-ID: <20160519163147.GH2890@piout.net>
References: <CALnQHM0edN=40GHHwRrOMkQEMsHk2haRoj21bwD2ySfYoLGVvA@mail.gmail.com>
 <CALnQHM0WbaPra2qV0ZoiS=CRy726OK+U=iBBPCFkh_4Lxs_z5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: David Mosberger <davidm@egauge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:59762 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753613AbcESQbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 12:31:50 -0400
Content-Disposition: inline
In-Reply-To: <CALnQHM0WbaPra2qV0ZoiS=CRy726OK+U=iBBPCFkh_4Lxs_z5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/05/2016 at 17:35:30 -0600, David Mosberger wrote :
> At 7.96 seconds, phy_start() gets called, but even though this enters
> state PHY_UP, it does not trigger phy_state_machine() and therefore
> doesn't trigger autonegotiation.  I'm not quite sure how this is
> intended to be handled properly.  I believe Alexandre Belloni's patch
> would do the trick:
> 
>  http://www.spinics.net/lists/netdev/msg373324.html
> 
> Or has this been fixed in some other way already?
> 

I don't think it has, last time I checked, Florian was still thinking
about it.

-- 
Alexandre Belloni, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
