From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio device
 tree nodes
Date: Wed, 22 May 2013 19:32:51 +0200
Message-ID: <519D0143.1000203@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369154510-4927-7-git-send-email-sebastian.hesselbarth@gmail.com> <20130521174849.GL26249@lunn.ch> <519C9333.20609@gmail.com> <519C9822.9040909@windriver.com> <519C9A66.3050807@gmail.com> <20130522131010.GB31290@titan.lakedaemon.net> <20130522165908.GB12320@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>,
	"tiejun.chen" <tiejun.chen@windriver.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130522165908.GB12320@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 06:59 PM, Jason Gunthorpe wrote:
> On Wed, May 22, 2013 at 09:10:10AM -0400, Jason Cooper wrote:
>> iirc, our solution to this was to parse the ATAGs for the mac addr and
>> update the appended dtb.  This way, module load and unload would work
>> without loosing the mac address.  I believe Jason Gunthorpe has a patch
>> to atags_to_fdt() for this...  This should allow us to get rid of the
>> clocks hack.
>
> Sorry, no, we don't use ATAGs here, our platforms start the kernel
> with a correct DTB that has the correct mac address to use. My patch
> was to have the driver accept it, and I think Sebastian has already
> got that functionality...

Not neccessary anyway, after talking Jason C in a Kirkwood-only
workaround I prepared a patch that reads mac address registers early
and stores it in the local-mac-address property.

Just tested on Dockstar with gated clocks and modular DT mv643xx_eth.

Will append to the DT mv643xx_eth patch set if a v5 will be required
or as single patch prior Jason C taking in the ARM part of it
otherwise.

Sebastian
