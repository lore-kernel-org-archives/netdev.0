From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC v2 18/32] dsa: mv88e6xxx: Prepare for turning this
 into a library module
Date: Mon, 29 Feb 2016 15:53:11 +0100
Message-ID: <20160229145311.GE1560@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <1456677700-23027-19-git-send-email-andrew@lunn.ch>
 <87io185jd3.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45510 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751744AbcB2OxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 09:53:14 -0500
Content-Disposition: inline
In-Reply-To: <87io185jd3.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 28, 2016 at 09:40:56PM -0500, Vivien Didelot wrote:
> Hi Andrew,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
> > Export all the functions so that we can later turn the module into a
> > library module.
> 
> As I mentioned in the first RFC [1], wouldn't that be preferable to
> avoid adding modules and factorize everything into a single one?
> 
> The common code would have a single probe function which calls
> mv88e6xxx_lookup_name for every model tables until it finds the good
> one.

Hi Vivien

This is all possible, but is not the point of what i'm trying to do
with this patchset. I want switch drivers to be linux devices, which
probe in the usual way. The changes i made here is the minimum needed
to allow that. What you are suggesting are further steps that could be
made. But since i already have 30 patches, i would prefer to get them
accepted and then think about this refactoring into one module. Such
refactoring should not change the device tree binding, so it can be
deferred.

	Andrew
