From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: Re: [PATCH 1/4] net: rfkill: gpio: remove unused and obsolete
 platform parameters
Date: Fri, 21 Feb 2014 16:23:49 +0200
Message-ID: <20140221142349.GB10489@xps8300>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
 <1392900697-27577-2-git-send-email-heikki.krogerus@linux.intel.com>
 <1723302.jKkc8NDNRI@fb07-iapwap2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marc Dietrich <marvin24@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1723302.jKkc8NDNRI@fb07-iapwap2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Feb 21, 2014 at 02:55:14PM +0100, Marc Dietrich wrote:
> Am Donnerstag, 20. Februar 2014, 14:51:34 schrieb Heikki Krogerus:
> > After upgrading to descriptor based gpios, the gpio numbers
> > are not used anymore. The power_clk_name and the platform
> > specific setup and close hooks are not used by anybody, and
> > we should not encourage use of such things, so removing them.
> 
> arch/arm/mach-tegra/board-paz00.c is still using platform data. Is there some 
> prerequisite patch I'm missing (3.14-rc3) or how can this file be converted? 
> We are waiting for DT support to arrive so we can finally remove this file.

True! It still set's the shutdown_gpio and reset_gpio members. I think
I'll leave the header untouched and just clean net/rfkill/rfkill-gpio.c
in this patch. We can remove the whole header after you guys have moved
to DT.

I'll prepare v2 next week.

Thanks!

-- 
heikki
