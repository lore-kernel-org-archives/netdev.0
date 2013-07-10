From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [GIT] Networking
Date: Wed, 10 Jul 2013 14:50:51 +0200
Message-ID: <20130710125051.GB357@x4>
References: <20130709.145325.1363244885668360965.davem@davemloft.net>
 <20130710122523.GA357@x4>
 <CA+5PVA5AT0OLNi-=x91ks5AbigymE3BDmdoEiiNOeRoGFCFQfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+5PVA5AT0OLNi-=x91ks5AbigymE3BDmdoEiiNOeRoGFCFQfg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013.07.10 at 08:43 -0400, Josh Boyer wrote:
> On Wed, Jul 10, 2013 at 8:25 AM, Markus Trippelsdorf
> <markus@trippelsdorf.de> wrote:
> > On 2013.07.09 at 14:53 -0700, David Miller wrote:
> >>
> >> Alexey Brodkin (2):
> >>       ethernet/arc/arc_emac - Add new driver
> >>       arc_emac: fix compile-time errors & warnings on PPC64
> >
> > This driver defaults to y for no reason:
> >
> > +config NET_VENDOR_ARC
> > +       bool "ARC devices"
> > +       default y
> 
> That's the option to enable the ARC vendor, not the driver.  The
> driver config option is ARC_EMAC.  All of the other ethernet vendors
> also default to y, so I don't think this is out of line.

Ah, I just noticed it while running "make" on the freshly pulled kernel
tree. 
But you're right.  Sorry for the noise.

-- 
Markus
