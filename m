From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio
 device tree nodes
Date: Wed, 22 May 2013 13:35:05 -0400
Message-ID: <20130522173505.GH31290@titan.lakedaemon.net>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-7-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130521174849.GL26249@lunn.ch> <519C9333.20609@gmail.com>
 <519C9822.9040909@windriver.com> <519C9A66.3050807@gmail.com>
 <20130522131010.GB31290@titan.lakedaemon.net>
 <20130522165908.GB12320@obsidianresearch.com>
 <519D0143.1000203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
 "tiejun.chen" <tiejun.chen@windriver.com>,
 Lennert Buytenhek <buytenh@wantstofly.org>, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <519D0143.1000203@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 07:32:51PM +0200, Sebastian Hesselbarth wrote:
> On 05/22/2013 06:59 PM, Jason Gunthorpe wrote:
> >On Wed, May 22, 2013 at 09:10:10AM -0400, Jason Cooper wrote:
> >>iirc, our solution to this was to parse the ATAGs for the mac addr and
> >>update the appended dtb.  This way, module load and unload would work
> >>without loosing the mac address.  I believe Jason Gunthorpe has a patch
> >>to atags_to_fdt() for this...  This should allow us to get rid of the
> >>clocks hack.
> >
> >Sorry, no, we don't use ATAGs here, our platforms start the kernel
> >with a correct DTB that has the correct mac address to use. My patch
> >was to have the driver accept it, and I think Sebastian has already
> >got that functionality...
> 
> Not neccessary anyway, after talking Jason C in a Kirkwood-only
> workaround I prepared a patch that reads mac address registers early
> and stores it in the local-mac-address property.

Sweet!

> Just tested on Dockstar with gated clocks and modular DT mv643xx_eth.
> 
> Will append to the DT mv643xx_eth patch set if a v5 will be required
> or as single patch prior Jason C taking in the ARM part of it
> otherwise.

Please post, in-reply-to v4 is fine.

thx,

Jason.
