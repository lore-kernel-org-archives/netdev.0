From: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Subject: Re: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002) on
 DEC Alpha Personal Workstation 433au
Date: Wed, 7 Apr 2010 15:42:28 +0200
Message-ID: <20100407134228.GC31252@physik.fu-berlin.de>
References: <20100405171318.GA18915@physik.fu-berlin.de>
 <1270488982.31062.28.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1270488982.31062.28.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Apr 05, 2010 at 10:36:22AM -0700, Joe Perches wrote:
> On Mon, 2010-04-05 at 19:13 +0200, Adrian Glaubitz wrote:
> > Hi guys,
> > 
> > I installed Debian unstable on an old digital workstation "DEC Digital
> > Personal Workstation 433au" (Miata) which has an on-board tulip
> > network controller. I'm not really using that network controller but
> > an off-board intel e1000 controller. However, I found that the tulip
> > driver produces a lot of noise in the message log, the following
> > message is repated periodically and spams the whole message log:
> > 
> > 0000:00:03.0: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002)
> > 
> > Do you think this is related to the fact that no cable is connected to
> > the network controller?
> 
> Probably something is trying periodically to open the device.
> Maybe this helps reduce the message log noise:
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>

Patch works perfectly. Now the message log looks pretty normal.

Thanks,

Adrian
