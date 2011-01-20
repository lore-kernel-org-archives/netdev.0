From: Dirk Brandewie <dirk.j.brandewie@intel.com>
Subject: Re: [PATCH] e1000: add support for Marvell Alaska M88E1118R PHY
Date: Thu, 20 Jan 2011 10:49:19 -0800
Message-ID: <1295549359.7387.30.camel@localhost.localdomain>
References: <201101191009.44707.ffainelli@freebox.fr>
	 <AANLkTinDh-ZnrZy3f5H72+FuNwvbnY-BnCns17+cpR=Z@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <ffainelli@freebox.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52192 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab1ATTTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 14:19:00 -0500
In-Reply-To: <AANLkTinDh-ZnrZy3f5H72+FuNwvbnY-BnCns17+cpR=Z@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-19 at 22:51 -0800, Jeff Kirsher wrote:
> On Wed, Jan 19, 2011 at 01:09, Florian Fainelli <ffainelli@freebox.fr> wrote:
> > From: Florian Fainelli <ffainelli@freebox.fr>
> >
> > This patch adds support for Marvell Alask M88E188R PHY chips. Support for
> > other M88* PHYs is already there, so there is nothing more to add than its
> > PHY id.
> >
> > Signed-off-by: Florian Fainelli <ffainelli@freebox.fr>
> > CC: Dirk Brandewie <dirk.j.brandewie@intel.com>
> > CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> 
> The patch itself looks fine.  I am concerned about validation.
> 
> Dirk - is there a chance that the ce4100 will use this PHY?  If so,
> can you cover the validation?

Florian is working on a CE4100 based platform.  It looks like they used
a different PHY from the Flacon Falls reference platform. I can't
directly test this patch since I don't have their hardware.  I will be
testing .38-rc1 next week on falcon falls.

I think the best we can do without the hardware is to compare the data
sheet for the new PHY with the PHYs already supported and make sure they
are compatible.  If the datasheets match up for the features the driver
is using this seems pretty low risk IMHO.

--Dirk
> 
> For now I will add this to my net-next tree while I await word from Dirk.
> 


