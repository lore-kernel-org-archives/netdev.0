From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH v2] [arch-x86] Allow SRAT integrity check to be skipped
Date: Thu, 02 Sep 2010 12:39:00 -0700
Message-ID: <1283456340.28591.23.camel@pjaxe>
References: <20100901225937.18457.16372.stgit@localhost.localdomain>
	 <1283427192.3793.100.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283427192.3793.100.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-02 at 04:33 -0700, Johannes Berg wrote:
> On Wed, 2010-09-01 at 15:59 -0700, Peter P Waskiewicz Jr wrote:
> 
> > +static int srat_bypass_bios;
> > +
> > +static int __init srat_bypass_bios_setup(char *str)
> > +{
> > +        srat_bypass_bios = 1;
> > +        return 0;
> > +}
> > +early_param("sratbypassbios", srat_bypass_bios_setup);
> > +
> >  /* Use the information discovered above to actually set up the nodes. */
> >  int __init acpi_scan_nodes(unsigned long start, unsigned long end)
> >  {
> 
> I wonder, since all the things using the variable are __init, could it
> be as well? Just curious really.

That is a good question.  It makes sense to me, but I just followed what
other boot-time options did, which are not marked __init.  I'll defer to
anyone else on the list who is better-equipped to answer that.

-PJ
