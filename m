From: Vinod Koul <vinod.koul@linux.intel.com>
Subject: Re: [PATCH linux-next] dmaengine: add context parameter fixups
Date: Mon, 26 Mar 2012 11:04:42 +0530
Message-ID: <1332740082.19804.15.camel@vkoul-udesk3>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	 <CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexandre Bounine <alexandre.bounine@idt.com>,
	paul.gortmaker@windriver.com, dan.j.williams@intel.com,
	samuel@sortiz.org, lrg@ti.com, perex@perex.cz, tiwai@suse.de,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, fabio.estevam@freescale.com,
	alsa-devel@alsa-project.org
To: Fabio Estevam <festevam@gmail.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-03-24 at 12:23 -0300, Fabio Estevam wrote:
> On Fri, Mar 23, 2012 at 11:00 AM, Alexandre Bounine
> <alexandre.bounine@idt.com> wrote:
> > This patch fixes drivers that use device_prep_slave_sg() and
> > device_prep_dma_cyclic() interfaces and have been missed during the initial
> > release of interface changing patches.
> >
> > This patch is based on linux-next-20120322 code tree.
> > See https://lkml.org/lkml/2012/3/22/339 for build failure report.
> >
> > Signed-off-by: Alexandre Bounine <alexandre.bounine@idt.com>
> > Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> > ---
> >  drivers/dma/sa11x0-dma.c      |    2 +-
> >  drivers/net/irda/sa1100_ir.c  |    2 +-
> >  sound/soc/sh/fsi.c            |    7 +++----
> >  sound/soc/soc-dmaengine-pcm.c |    2 +-
> 
> I have already taken care of sound/soc/soc-dmaengine-pcm.c:
> http://permalink.gmane.org/gmane.linux.alsa.devel/96215
And this seems to be linux-next.

Mark, Is this part of the sound updates that went to Linus?


-- 
~Vinod
