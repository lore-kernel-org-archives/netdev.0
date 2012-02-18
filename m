From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes in arch/blackfin
Date: Sat, 18 Feb 2012 14:28:06 +0100
Message-ID: <201202181428.07491.danny.kukawka@bisect.de>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de> <201202171815.59846.vapier@gentoo.org> <1329521263.584.50.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329521263.584.50.camel@joe2Laptop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Samstag, 18. Februar 2012, Joe Perches wrote:
> On Fri, 2012-02-17 at 18:15 -0500, Mike Frysinger wrote:
> > On Friday 17 February 2012 05:57:54 Danny Kukawka wrote:
> > > Maybe. Many drivers already print information about setting a random
> > > mac address to a netdevice. Some with printk, some via
> > > netdev_warn/netdev_info/netdev_dbg or netif_dbg and other with costum
> > > methods. I could unify this, in a next step with a netdev_info in
> > > eth_hw_addr_random(), if it's okay for David.
> >
> > i think unification in the core makes sense.  it enforces consistency and
> > removes duplication.
>
> It's a good idea.

Okay ... I'll send a patch to print a message via netdev_info from 
eth_hw_addr_random() and to cleanup the drivers.

Danny
