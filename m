From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Thu, 14 Jul 2016 09:15:11 -0700
Message-ID: <20160714161511.GA30697@u54ee753d2d1854bda401.ant.amazon.com>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160714152215.GA24590@u54ee753d2d1854bda401.ant.amazon.com>
 <20160714160803.egrmos7soc6qvrry@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netanel Belgazal <netanel@annapurnalabs.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com,
	aliguori@amazon.com, ben@decadent.org.uk, romieu@fr.zoreil.com,
	rami.rosen@intel.com, antoine.tenart@free-electrons.com,
	"John W. Linville" <linville@tuxdriver.com>
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160714160803.egrmos7soc6qvrry@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 14, 2016 at 09:08:03AM -0700, Benjamin Poirier wrote:
> On 2016/07/14 08:22, Matt Wilson wrote:
> [...]
> > 
> > Dave and Benjamin,
> > 
> > Do you want to see the interrupt moderation extensions to ethtool and
> > the sysfs nodes removed before this lands in net-next? Or should
> > Netanel remove the sysfs bits until we can extend the ethtool
> > interfaces to cover the parameters that ena uses?
> 
> I couldn't say what's acceptable or not. A few other drivers (qlcnic,
> sfc, ...) already have sysfs tunables. Maybe John, as the new ethtool
> maintainer, can weight in too about the changes required to ethtool.

We definitely want ethtool to handle all the settings, it's just a
question of when. We also want to address and resolve all the great
feedback so far, and since you originally raised the point about
extending ethtool I wanted to see if you have any major objection.

--msw
