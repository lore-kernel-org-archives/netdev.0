From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH v2 09/13] net: Rework pasemi_mac driver to use of_mdio
	infrastructure
Date: Sun, 22 Mar 2009 15:11:35 -0500
Message-ID: <20090322201135.GA9592@lixom.net>
References: <20090321222047.20493.87335.stgit@localhost.localdomain> <20090321222901.20493.67103.stgit@localhost.localdomain> <20090322154710.GA6473@lixom.net> <fa686aa40903221136k5a926381u69fe6e57b927d1d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, galak@kernel.crashing.org,
	davem@davemloft.net
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:43864 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587AbZCVUHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2009 16:07:01 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa40903221136k5a926381u69fe6e57b927d1d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2009 at 12:36:44PM -0600, Grant Likely wrote:
> On Sun, Mar 22, 2009 at 9:47 AM, Olof Johansson <olof@lixom.net> wrote:
> > Did you ever try building it? pasemi_defconfig gives me:
> 
> No.  I mentioned it in the series header email, but not in the patch
> description.  My 64bit build environment is broken at the moment so I
> couldn't build test the pasemi patch.  All the others are build
> tested.  I'll have it sorted out before I post v3.

Ah, my bad. I just glanced it over looking for the git URL. :)

> > The changes needed are trivial, include <linux/of_mdio.h> and remove the
> > variables, label and following code. I could send a patch but that's likely
> > more of a hassle than you fixing it up yourself?
> 
> Yeah, I'll fix it.  Thanks for the testing.
> 
> > Otherwise, with the above changes, seems to test out ok on my Electra.
> > When you checkin the changes, feel free to add:
> 
> Awesome.  Thanks for the testing.

NP! Thanks for doing this cleanup!


-Olof
