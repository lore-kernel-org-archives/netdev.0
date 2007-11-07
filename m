From: David Brownell <david-b@pacbell.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function `usbnet_set_settings':
Date: Wed, 7 Nov 2007 14:34:52 -0800
Message-ID: <200711071434.52607.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711021230.22588.david-b@pacbell.net> <20071102195517.GW30287@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.sbc.mail.mud.yahoo.com ([68.142.198.208]:48642 "HELO
	smtp109.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755048AbXKGWe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 17:34:58 -0500
In-Reply-To: <20071102195517.GW30287@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > But on the other hand, it seems that only the ASIX code will work
> > right; the DM9601 and MCS7830 Kconfig is different/wrong.
> 
> I'm not seeing the problem.
> 
> Which configuration will be handled wrongly?

Notice how only the ASIX kconfig depended on NET_ETHERNET...
since MII depends on NET_ETHERNET, and (last I knew) the
reverse dependencies didn't capture the complete dependency
tree, selecting only MII would leave out some stuff.


