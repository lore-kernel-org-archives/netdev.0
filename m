From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] drivers/atm/lanai.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 21:56:59 -0200
Message-ID: <20091230235659.GH18722@khazad-dum.debian.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F645@mi8nycmail19.Mi8.com>
 <1262199586.2545.43.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752191AbZL3X5I@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1262199586.2545.43.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Dec 2009, Joe Perches wrote:
> > +		return sprintf(page, "EEPROM ESI: %pM\n",
> > +		    &lanai->eeprom[EEPROM_MAC]);
> 
> This is a user-visible change from upper case to lower case.
> Probably doesn't matter, but maybe...

Something would need to be _really_ broken to:

1. Parse the kernel log after MACs in the first place
2. Be case-sensitive about it

If it breaks anything, it is a breakage well deserved...

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
