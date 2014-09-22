From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: net/fec: Unable to get a permanent link when connecting to a
 PC
Date: Mon, 22 Sep 2014 10:06:14 +0200
Message-ID: <541FD876.4090109@i2se.com>
References: <1XUuZV-0zjkn20@fwd01.aul.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: "to-fleischer@t-online.de" <to-fleischer@t-online.de>,
	linux-arm-kernel@lists.infradead.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:59509 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbaIVIHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 04:07:06 -0400
In-Reply-To: <1XUuZV-0zjkn20@fwd01.aul.t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.09.2014 um 11:33 schrieb to-fleischer@t-online.de:
> I have an i.MX283 board with a KSZ8081 PHY that is connected to the controller
> via RMII. The PHY's interrupt line is currently unused, but connected to the
> controller. The board runs the linux version 3.17-rc5.
> When I connect the board directly to a PC the ethernet link goes up and a second
> later down. This is repeated again and again.
> After some investigation I found that this is caused by the reset of the FEC at
> the begin of fec_restart() that is called by fec_enet_adjust_link() if the link
> is up.
> Due to the reset the mode is set to MII. After switching back to RMII the PHY 
> seems to restart the autonegotiation. Since this takes a while the next call of 
> phy_state_machine() detects that the link is down.
> It would work, if the reset in fec_restart is avoided for the case that the link
> goes up and the fec is still stopped.
>
> Its quite remarkable that this issue does not occur if I connect the board to a
> switch or if I use the PHY's interrupt line.
>
> What do you think?
>
> Best Regards,
> Torsten Fleischer
>

Add netdev list

Best regards
Stefan Wahren
