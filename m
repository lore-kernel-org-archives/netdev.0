From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] 2.6.3 orinoco.c patch to support ethtool get_link
Date: Mon, 8 Mar 2004 10:52:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308185242.GA18367@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Thomas Munck Steenholdt <tmus@tmus.dk>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Munck Steenholdt wrote :
> 
> I noticed that there wasn't a good way, from userland, to get the link
> status of an orinoco device.

	I hope you realise that most often link status is meaningless
with Wireless cards. In Ad-Hoc mode, the link is always up, regardless
of the number of nodes in the cell, check the discussion on the HostAP
mailing list. And the Orinoco card will report connected even is WEP
is wrong. But, if you only use managed mode without WEP, that should
work.
	I just wonder if it's better to report a 'link status' that
may be wrong/misleading or to not report anything at all.

	Have fun...

	Jean
