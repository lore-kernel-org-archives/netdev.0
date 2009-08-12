From: Daniel Mack <daniel@caiaq.de>
Subject: Re: [PATCH] libertas: name the network device wlan%d
Date: Wed, 12 Aug 2009 10:55:46 +0200
Message-ID: <20090812085546.GA9464@buzzloop.caiaq.de>
References: <1250000012-25673-1-git-send-email-daniel@caiaq.de> <20090811143401.GD2684@tuxdriver.com> <20090812075624.GC18186@guralp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Roel Kluin <roel.kluin@gmail.com>,
	libertas-dev@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:56927 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143AbZHLIzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 04:55:49 -0400
Content-Disposition: inline
In-Reply-To: <20090812075624.GC18186@guralp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 12, 2009 at 08:56:24AM +0100, Bob Dunlop wrote:
> > > 
> > > Fix this by calling it wlan%d.
> > > 
> > I'm fine with changing it, but it isn't really wrong either -- it's
> > just a name, and afterall in most cases all the user will see is
> > ethernet frames.
> > 
> > Comments from the libertas driver crew?
> 
> Well I've been applying the equivalent of this patch privately since
> we started using the libertas driver.  We build systems with one or two
> wired Ethernets and then an optional wireless module.
> 
> A fixed name wlan0 is a lot easier than explaining to a user that the
> interface might be eth1 or eth2 depending on which model they have, or
> that eth1 might be wired or wireless.  It also simplifies scripts and
> configuration file handling.
> 
> I'm sure there are many other solutions for big systems but this is
> really simple for small boys.

Yes, our story here is very similar :)

