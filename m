From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 1/8] macb: unify at91 and avr32 platform data
Date: Fri, 11 Mar 2011 02:41:40 +0100
Message-ID: <20110311014140.GI9351@game.jcrosoft.org>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
	<1299751843-9743-2-git-send-email-jamie@jamieiles.com>
	<4D78CCBC.2010807@atmel.com>
	<20110310131724.GG6198@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110310131724.GG6198@pulham.picochip.com>
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

On 13:17 Thu 10 Mar     , Jamie Iles wrote:
> On Thu, Mar 10, 2011 at 02:06:04PM +0100, Nicolas Ferre wrote:
> > On 3/10/2011 11:10 AM, Jamie Iles :
> > > --- a/drivers/net/macb.c
> > > +++ b/drivers/net/macb.c
> > > @@ -18,12 +18,10 @@
> > >  #include <linux/netdevice.h>
> > >  #include <linux/etherdevice.h>
> > >  #include <linux/dma-mapping.h>
> > > +#include <linux/platform_data/macb.h>
> > >  #include <linux/platform_device.h>
> > >  #include <linux/phy.h>
> > >  
> > > -#include <mach/board.h>
> > > -#include <mach/cpu.h>
> > 
> > I did not bouble check but do we need no more cpu_is_ macros?
> 
> No, I couldn't see any in there and it builds for all of the AT91 
> targets and all of the AVR32 ones that I tried.  I can't see any macros 
> in there that are likely to use cpu_is_* internally either.
keep as we need to remove the #ifdef AT91 to cpu_is

I've patch for this

Best Regards,
J.
