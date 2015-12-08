From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v9, 6/6] fsl/fman: Add FMan MAC driver
Date: Tue, 8 Dec 2015 16:44:38 -0600
Message-ID: <1449614678.15946.152.camel@freescale.com>
References: <1449127157-9400-1-git-send-email-igal.liberman@freescale.com>
	 <1449127157-9400-7-git-send-email-igal.liberman@freescale.com>
	 <CAKWjMd7EDx8OnYGu-QJXM++fy=W5i2E74Fe4r9zNjUV_giyUKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<madalin.bucur@freescale.com>, <pebolle@tiscali.nl>,
	Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	<ppc@mindchasers.com>, <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
To: Andy Fleming <afleming@gmail.com>, <igal.liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKWjMd7EDx8OnYGu-QJXM++fy=W5i2E74Fe4r9zNjUV_giyUKw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-12-08 at 14:18 -0600, Andy Fleming wrote:
> On Thu, Dec 3, 2015 at 1:19 AM,  <igal.liberman@freescale.com> wrote:
> > From: Igal Liberman <igal.liberman@freescale.com>
> > 
> > This patch adds the Ethernet MAC driver supporting the three
> > different types of MACs: dTSEC, tGEC and mEMAC.
> > 
> > Signed-off-by: Igal Liberman <igal.liberman@freescale.com>
> 
> [...]
> 
> > +
> > +MODULE_LICENSE("Dual BSD/GPL");
> > +
> > +MODULE_AUTHOR("Emil Medve <Emilian.Medve@Freescale.com>");
> 
> I imagine this email address doesn't exist anymore, or won't soon.
> This is also an issue in the ethernet driver (with my old address).
> I'm not sure what the right approach is, but we shouldn't be putting
> obsolete email addresses in the kernel.

I don't think a MODULE_AUTHOR tag makes sense for drivers like this that had a
lot of people work on them.  git history is better for giving credit in such
cases.

-Scott
