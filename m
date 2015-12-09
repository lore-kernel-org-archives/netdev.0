From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [v9, 6/6] fsl/fman: Add FMan MAC driver
Date: Wed, 9 Dec 2015 10:10:10 +0000
Message-ID: <DM2PR0301MB0768A54B342C6AEB767A8739E6E80@DM2PR0301MB0768.namprd03.prod.outlook.com>
References: <1449127157-9400-7-git-send-email-igal.liberman@freescale.com>
	<CAKWjMd7EDx8OnYGu-QJXM++fy=W5i2E74Fe4r9zNjUV_giyUKw@mail.gmail.com>
	<1449614678.15946.152.camel@freescale.com>
 <20151208.211715.790899872740551674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "afleming@gmail.com" <afleming@gmail.com>,
	Liberman Igal <Igal.Liberman@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>,
	Scott Wood <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151208.211715.790899872740551674.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Scott Wood <scottwood@freescale.com>
> Date: Tue, 8 Dec 2015 16:44:38 -0600
> 
> > On Tue, 2015-12-08 at 14:18 -0600, Andy Fleming wrote:
> >> On Thu, Dec 3, 2015 at 1:19 AM,  <igal.liberman@freescale.com> wrote:
> >> > From: Igal Liberman <igal.liberman@freescale.com>
> >> >
> >> > This patch adds the Ethernet MAC driver supporting the three
> >> > different types of MACs: dTSEC, tGEC and mEMAC.
> >> >
> >> > Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
> >>
> >> [...]
> >>
> >> > +
> >> > +MODULE_LICENSE("Dual BSD/GPL");
> >> > +
> >> > +MODULE_AUTHOR("Emil Medve <Emilian.Medve@Freescale.com>");
> >>
> >> I imagine this email address doesn't exist anymore, or won't soon.
> >> This is also an issue in the ethernet driver (with my old address).
> >> I'm not sure what the right approach is, but we shouldn't be putting
> >> obsolete email addresses in the kernel.
> >
> > I don't think a MODULE_AUTHOR tag makes sense for drivers like this that
> had a
> > lot of people work on them.  git history is better for giving credit in
> such
> > cases.
> 
> Agreed.

I've already removed the MODULE_AUTHOR tag from the dpaa_eth code, this will
be removed as well. We are required to keep the Signed-off by: tags of the
original authors for the patches and also were instructed to keep the original
Freescale email addresses even if the patch authors have different email
addresses now. To complicate things further, after the Freescale - NXP merger
the freescale.com employee emails will be replaced by nxp.com email addresses
so our future submissions will have a mix of legacy freescale.com emails for
the former employees and nxp.com for the current ones. Given that the Freescale
brand is replaced with NXP, we may need to reflect this in the folder structure,
prefixes used in the code, etc. Copyright will also need to reflect this change,
any further changes will be attributed to NXP. Is there a norm/custom followed
in such situations?

Madalin
