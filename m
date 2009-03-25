From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 15/61] net: struct device - replace bus_id with
	dev_name(), dev_set_name()
Date: Tue, 24 Mar 2009 21:18:39 -0700
Message-ID: <20090325041839.GB27737@suse.de>
References: <20090325001659.GA22461@kroah.com> <1237940825-22904-15-git-send-email-gregkh@suse.de> <20090324203111.0d3f5de1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:57063 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbZCYEb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 00:31:27 -0400
Content-Disposition: inline
In-Reply-To: <20090324203111.0d3f5de1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 08:31:11PM -0700, Stephen Hemminger wrote:
> On Tue, 24 Mar 2009 17:26:19 -0700
> Greg Kroah-Hartman <gregkh@suse.de> wrote:
> 
> > From: Kay Sievers <kay.sievers@vrfy.org>
> > 
> > Cc: davem@davemloft.net
> > Cc: netdev@vger.kernel.org
> > Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> > Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
> > ---
> >  drivers/net/arm/ks8695net.c  |    2 +-
> >  drivers/net/au1000_eth.c     |    8 ++++----
> >  drivers/net/bfin_mac.c       |   12 ++++++------
> >  drivers/net/bmac.c           |    2 +-
> >  drivers/net/cpmac.c          |    2 +-
> >  drivers/net/declance.c       |    6 +++---
> >  drivers/net/depca.c          |    6 +++---
> >  drivers/net/ehea/ehea_main.c |    2 +-
> >  drivers/net/jazzsonic.c      |    6 ++++--
> >  drivers/net/macb.c           |   10 +++++-----
> >  drivers/net/macsonic.c       |   15 ++++++++-------
> >  drivers/net/mv643xx_eth.c    |    2 +-
> >  drivers/net/sb1250-mac.c     |   10 +++++-----
> >  drivers/net/smc911x.c        |    2 +-
> >  drivers/net/smc91x.c         |    2 +-
> >  drivers/net/smsc911x.c       |    7 ++++---
> >  drivers/net/smsc9420.c       |    4 ++--
> >  drivers/net/tc35815.c        |    4 ++--
> >  drivers/net/xtsonic.c        |    2 +-
> >  19 files changed, 54 insertions(+), 50 deletions(-)
> > 
> 
> I know this is needed, but could please put some more explicit rational
> in changelog.

bus_id is going away, much more rational isn't really needed :)

thanks,

greg k-h
