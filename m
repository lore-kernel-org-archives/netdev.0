From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH] netdev: mv643xx_eth: Prevent build on PPC32
Date: Fri, 8 Jun 2012 01:34:45 +0100
Message-ID: <20120608003445.GC21150@sirena.org.uk>
References: <20120605192820.GC7683@zod.bos.redhat.com>
 <1338939005.21665.54.camel@deadeye.wl.decadent.org.uk>
 <20120606023842.GD7683@zod.bos.redhat.com>
 <20120607235115.GB21150@sirena.org.uk>
 <20120607235550.GK7683@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>,
	netdev@vger.kernel.org
To: Josh Boyer <jwboyer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:33188 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757336Ab2FHAes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 20:34:48 -0400
Content-Disposition: inline
In-Reply-To: <20120607235550.GK7683@zod.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 07, 2012 at 07:55:51PM -0400, Josh Boyer wrote:
> On Fri, Jun 08, 2012 at 12:51:15AM +0100, Mark Brown wrote:

> > This sort of issue is just the tip of the iceberg in terms of what it's
> > useful to do with the API.

> Yes, sounds like it.  All I ask is that people test their patches along
> the way so things don't get broken.  I mean, it's great we have an
> iceberg but I don't want tons of drivers on other architectures running
> into the thing and sinking because people aren't being careful.  Except
> maybe the one already appropriately (nick)named.

It's really hard to blame the submitters here - this really isn't the
sort of API that you'd expect to only be available conditionally so this
isn't something that one would expect to have to worry about.  It's a
product of the age of the clock API and the glacial progress on the
generic clock API.
