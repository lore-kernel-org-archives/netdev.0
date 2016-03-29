From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 2/2] net: dsa: mv88e6xxx: Clear the PDOWN bit
 on setup
Date: Tue, 29 Mar 2016 18:28:25 +0200
Message-ID: <20160329162825.GC4690@lunn.ch>
References: <1459249908-4556-1-git-send-email-patrick@puiterwijk.org>
 <1459249908-4556-2-git-send-email-patrick@puiterwijk.org>
 <87fuv9fe39.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick Uiterwijk <patrick@puiterwijk.org>, linux@roeck-us.net,
	davem@davemloft.net, netdev@vger.kernel.org, dennis@ausil.us,
	pbrobinson@gmail.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42025 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517AbcC2Q2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2016 12:28:36 -0400
Content-Disposition: inline
In-Reply-To: <87fuv9fe39.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2016 at 12:23:06PM -0400, Vivien Didelot wrote:
> Hi Patrick,
> 
> Two comments below.
> 
> Patrick Uiterwijk <patrick@puiterwijk.org> writes:
> 
> > +static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
> 
> Since this function assumes the SMI lock is already held, its name
> should be prefixed with _ by convention (_mv88e6xxx_power_on_serdes).

We decided to drop at, since nearly everything would end up with a _
prefix. The assert_smi_lock() should find any missing locks, and
lockdep/deadlocks will make it clear when the lock is taken twice.

	  Andrew
