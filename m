From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio
 device tree nodes
Date: Wed, 22 May 2013 13:01:57 -0400
Message-ID: <20130522170157.GF31290@titan.lakedaemon.net>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-7-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130521174849.GL26249@lunn.ch>
 <519C9333.20609@gmail.com>
 <519C9822.9040909@windriver.com>
 <519C9A66.3050807@gmail.com>
 <20130522131010.GB31290@titan.lakedaemon.net>
 <20130522165908.GB12320@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"tiejun.chen" <tiejun.chen@windriver.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130522165908.GB12320@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 10:59:08AM -0600, Jason Gunthorpe wrote:
> On Wed, May 22, 2013 at 09:10:10AM -0400, Jason Cooper wrote:
> 
> > iirc, our solution to this was to parse the ATAGs for the mac addr and
> > update the appended dtb.  This way, module load and unload would work
> > without loosing the mac address.  I believe Jason Gunthorpe has a patch
> > to atags_to_fdt() for this...  This should allow us to get rid of the
> > clocks hack.
> 
> Sorry, no, we don't use ATAGs here, our platforms start the kernel
> with a correct DTB that has the correct mac address to use. My patch
> was to have the driver accept it, and I think Sebastian has already
> got that functionality...

Yes, you're right.

thx,

Jason.
