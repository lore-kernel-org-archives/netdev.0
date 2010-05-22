From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 1/5] net/phy/marvell: Expose IDs and flags in a .h and
	add dns323 LEDs setup flag
Date: Sun, 23 May 2010 08:53:34 +1000
Message-ID: <1274568814.1931.148.camel@pasglop>
References: <1274525683.1931.139.camel@pasglop>
	<20100522130624.GA28561@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, Nicolas Pitre <nico@fluxnic.net>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100522130624.GA28561@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-05-22 at 15:06 +0200, Wolfram Sang wrote:
> On Sat, May 22, 2010 at 08:54:43PM +1000, Benjamin Herrenschmidt wrote:
> > This moves the various known Marvell PHY IDs to include/linux/marvell_phy.h
> > along with dev_flags definitions for use by the driver.
> 
> I think this one from the driver should go there, too:
> 
> #define M1145_DEV_FLAGS_RESISTANCE      0x00000001
> 
> (which makes me wonder how this flag was set as it was not exported before)

I missed that one indeed.

> and thus yours could be maybe like
> 
> #define M1118_DEV_FLAGS_ALT_LED_INIT	0x00000001
> 
> (or 1 << 0)

Right, it should be 2. I'd rather keep the "DNS323" name in there
since the LED setup is specific to that NAS and somebody else might
need a different one. If we end up in the long run with too many
of them, we'll find a better solution, but we aren't there yet.

> Otherwise looks good enough to me.

Ok, thanks. I'll respin the whole lot soon.

Cheers,
Ben.
