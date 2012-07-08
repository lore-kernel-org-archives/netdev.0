From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Sun, 8 Jul 2012 16:50:56 +0100
Message-ID: <1341762656.25597.230.camel@deadeye.wl.decadent.org.uk>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	 <1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <1341761975.2038.28.camel@schesaplana>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Riesch <christian.riesch@omicron.at>,
	<netdev@vger.kernel.org>, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>
To: <michael@riesch.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25051 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751859Ab2GHPvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 11:51:02 -0400
In-Reply-To: <1341761975.2038.28.camel@schesaplana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-08 at 17:39 +0200, Michael Riesch wrote:
> On Fri, 2012-07-06 at 18:37 +0100, Ben Hutchings wrote:
> > > +	priv->mdio->priv = (void *)dev;
> > > +	priv->mdio->read = &asix_mdio_bus_read;
> > > +	priv->mdio->write = &asix_mdio_bus_write;
> > > +	priv->mdio->name = "Asix MDIO Bus";
> > > +	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%s",
> > > +		 dev_name(dev->net->dev.parent));
> > [...]
> > 
> > I think you need to ensure that the bus identifier is unique throughout
> > its lifetime, but net devices can be renamed and that could lead to a
> > collision.  Perhaps you could use the ifindex or the USB device path
> 
> Ben,
> 
> the dev_name function in the code above returns the sysfs filename of
> the USB device (e.g. 1-0:1.0).
[...]

Sorry, I didn't read that carefully enough.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
