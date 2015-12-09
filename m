From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v9, 6/6] fsl/fman: Add FMan MAC driver
Date: Wed, 9 Dec 2015 11:07:13 -0600
Message-ID: <1449680833.15946.184.camel@freescale.com>
References: <1449127157-9400-7-git-send-email-igal.liberman@freescale.com>
	 <CAKWjMd7EDx8OnYGu-QJXM++fy=W5i2E74Fe4r9zNjUV_giyUKw@mail.gmail.com>
	 <1449614678.15946.152.camel@freescale.com>
	 <20151208.211715.790899872740551674.davem@davemloft.net>
	 <DM2PR0301MB0768A54B342C6AEB767A8739E6E80@DM2PR0301MB0768.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "afleming@gmail.com" <afleming@gmail.com>,
	Liberman Igal-B31950 <Igal.Liberman@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM2PR0301MB0768A54B342C6AEB767A8739E6E80@DM2PR0301MB0768.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-09 at 04:10 -0600, Bucur Madalin-Cristian-B32716 wrote:
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > 
> > From: Scott Wood <scottwood@freescale.com>
> > Date: Tue, 8 Dec 2015 16:44:38 -0600
> > 
> > > On Tue, 2015-12-08 at 14:18 -0600, Andy Fleming wrote:
> > > > On Thu, Dec 3, 2015 at 1:19 AM,  <igal.liberman@freescale.com> wrote:
> > > > > From: Igal Liberman <igal.liberman@freescale.com>
> > > > > 
> > > > > This patch adds the Ethernet MAC driver supporting the three
> > > > > different types of MACs: dTSEC, tGEC and mEMAC.
> > > > > 
> > > > > Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
> > > > 
> > > > [...]
> > > > 
> > > > > +
> > > > > +MODULE_LICENSE("Dual BSD/GPL");
> > > > > +
> > > > > +MODULE_AUTHOR("Emil Medve <Emilian.Medve@Freescale.com>");
> > > > 
> > > > I imagine this email address doesn't exist anymore, or won't soon.
> > > > This is also an issue in the ethernet driver (with my old address).
> > > > I'm not sure what the right approach is, but we shouldn't be putting
> > > > obsolete email addresses in the kernel.
> > > 
> > > I don't think a MODULE_AUTHOR tag makes sense for drivers like this that
> > had a
> > > lot of people work on them.  git history is better for giving credit in
> > such
> > > cases.
> > 
> > Agreed.
> 
> I've already removed the MODULE_AUTHOR tag from the dpaa_eth code, this will
> be removed as well. We are required to keep the Signed-off by: tags of the
> original authors for the patches and also were instructed to keep the
> original
> Freescale email addresses even if the patch authors have different email
> addresses now.

What does it mean to say that you're "keeping" the Signed-off-by when that
signoff was made on a very different patch and/or some smaller patch that got
squashed in?  You only need to include other people's signoff if you're
passing the patch on under section (c) of the DCO.  In this case you can use
section (a), and just write a sentence in the changelog giving any appropriate
credit to others.

-Scott
