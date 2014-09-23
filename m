From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 12:17:55 -0700
Message-ID: <1411499875.29268.7.camel@joe-AO725>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
	 <20140923072251.GD4657@distanz.ch>
	 <20140923094614.GA5130@leicester.auvation.com>
	 <20140923190242.GA8096@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark Einon <mark.einon@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	gregkh@linuxfoundation.org, davem@davemloft.net,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0022.hostedemail.com ([216.40.44.22]:44102 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751638AbaIWTR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 15:17:59 -0400
In-Reply-To: <20140923190242.GA8096@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-23 at 21:02 +0200, Francois Romieu wrote:
> Mark Einon <mark.einon@gmail.com> :
> [...]
> > > No need for the #define here, just assigne et131x_pm_ops to .driver.pm
> > > directly, its members will be NULL and thus never called. Also, you can
> > > make et131x_pm_ops const.
> > 
> > Ok, I can change this.
> > 
> > Btw, this appears to be a fairly standard way of using .driver.pm among
> > ethernet drivers, e.g. see 3com/3c59x.c, atheros, marvell... - perhaps
> > there is a case for changing all instances of this code?
> 
> How about kernel tinification ?

The tiny case where a large number of ethernet drivers are included?
