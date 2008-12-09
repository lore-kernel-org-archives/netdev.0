From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] net (tg3): Fix failure to enable WoL by default
 when possible (rev. 2)
Date: Tue, 9 Dec 2008 12:39:46 -0800
Message-ID: <20081209203946.GB29327@xw6200.broadcom.net>
References: <200812081250.59095.rjw@sisk.pl>
 <20081208190403.GA27341@xw6200.broadcom.net>
 <20081209.002007.203471603.davem@davemloft.net>
 <200812092126.35902.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4536 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757719AbYLIUkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 15:40:08 -0500
In-Reply-To: <200812092126.35902.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure.  I'll do it.  Standby.

On Tue, Dec 09, 2008 at 12:26:35PM -0800, Rafael J. Wysocki wrote:
> On Tuesday, 9 of December 2008, David Miller wrote:
> > From: "Matt Carlson" <mcarlson@broadcom.com>
> > Date: Mon, 8 Dec 2008 11:04:03 -0800
> > 
> > > This has mostly been fixed up already in Dave Miller's tree.  In that
> > > tree, the WOL capability advertisements happens at the end of the
> > > tg3_get_eeprom_hw_cfg() function.
> > > 
> > > Your patch did uncover a bug though.  The removal of device_may_wakeup()
> > > in the first hunk of your patch still needs to be done.
> > 
> > Ok, can someone post a patch that takes care of that against
> > net-next-2.6?
> 
> Matt, are you going to take care of this or do you want me to do that?
> 
> Rafael
> 

