From: "Igal.Liberman@freescale.com" <Igal.Liberman@freescale.com>
Subject: RE: [RFC,1/8] soc/fman: Add FMan MURAM support
Date: Mon, 20 Apr 2015 08:58:20 +0000
Message-ID: <DM2PR03MB3835BC56CD47613CB1AD4EBE6E00@DM2PR03MB383.namprd03.prod.outlook.com>
References: <1426050469-12507-1-git-send-email-igal.liberman@freescale.com>
 <32CF85E2-A8AA-454D-A46F-0E778DAF97ED@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <32CF85E2-A8AA-454D-A46F-0E778DAF97ED@kernel.crashing.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Regards,
Igal Liberman.

> -----Original Message-----
> From: Kumar Gala [mailto:galak@kernel.crashing.org]
> Sent: Thursday, March 12, 2015 5:57 PM
> To: Liberman Igal-B31950
> Cc: linuxppc-dev@lists.ozlabs.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Wood Scott-B07421
> Subject: Re: [RFC,1/8] soc/fman: Add FMan MURAM support
> 
> 
> On Mar 11, 2015, at 12:07 AM, Igal.Liberman <igal.liberman@freescale.com>
> wrote:
> 
> > From: Igal Liberman <Igal.Liberman@freescale.com>
> >
> > Add Frame Manager Multi-User RAM support.
> >
> > Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> > ---
> > drivers/soc/fsl/fman/Kconfig            |    1 +
> > drivers/soc/fsl/fman/Makefile           |    5 +-
> > drivers/soc/fsl/fman/fm_muram.c         |  174
> +++++++++++++++++++++++++++++++
> > drivers/soc/fsl/fman/inc/fm_muram_ext.h |   98 +++++++++++++++++
> > 4 files changed, 276 insertions(+), 2 deletions(-) create mode 100644
> > drivers/soc/fsl/fman/fm_muram.c create mode 100644
> > drivers/soc/fsl/fman/inc/fm_muram_ext.h
> >
> 
> use lib/genalloc instead of rheap
> 

Hi Kumar,
I looked into lib/genalloc allocator.
As far as I see, the genalloc allocator doesn't allow to control the memory alignment when you allocate a chunk of memory.
Two important notes regarding MURAM memory:
- The allocated memory chunks should have specific alignment (might be different in each chunk).
- The allocations must be efficient, we don't want to "waste" MURAM due to alignment issues.

> - k
