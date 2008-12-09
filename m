From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] net (tg3): Fix failure to enable WoL by default when possible (rev. 2)
Date: Tue, 9 Dec 2008 21:26:35 +0100
Message-ID: <200812092126.35902.rjw@sisk.pl>
References: <200812081250.59095.rjw@sisk.pl> <20081208190403.GA27341@xw6200.broadcom.net> <20081209.002007.203471603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:46108 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701AbYLIU1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 15:27:21 -0500
In-Reply-To: <20081209.002007.203471603.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, 9 of December 2008, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Mon, 8 Dec 2008 11:04:03 -0800
> 
> > This has mostly been fixed up already in Dave Miller's tree.  In that
> > tree, the WOL capability advertisements happens at the end of the
> > tg3_get_eeprom_hw_cfg() function.
> > 
> > Your patch did uncover a bug though.  The removal of device_may_wakeup()
> > in the first hunk of your patch still needs to be done.
> 
> Ok, can someone post a patch that takes care of that against
> net-next-2.6?

Matt, are you going to take care of this or do you want me to do that?

Rafael
