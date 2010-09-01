From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Wed, 01 Sep 2010 15:11:38 -0700
Message-ID: <1283379098.28591.20.camel@pjaxe>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
	 <41621.148.87.67.139.1283378664.squirrel@www.xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "rdunlap@xenotime.net" <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <41621.148.87.67.139.1283378664.squirrel@www.xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-01 at 15:04 -0700, rdunlap@xenotime.net wrote:
> On Wed, September 1, 2010 2:33 pm, Peter P Waskiewicz Jr wrote:
> > Documentation/x86/x86_64/boot-options.txt |    4 ++++
> > arch/x86/mm/srat_64.c                     |   20 +++++++++++++++++--- 2
> > files changed, 21 insertions(+), 3 deletions(-)
> >
> > diff --git a/arch/x86/mm/srat_64.c b/arch/x86/mm/srat_64.c index
> > f9897f7..8719472 100644 --- a/arch/x86/mm/srat_64.c
> > +++ b/arch/x86/mm/srat_64.c
> > @@ -351,6 +351,15 @@ int __init acpi_get_nodes(struct bootnode *physnodes)
> >  return ret; }
> >
> >
> > +int srat_bypass_bios = 0;
> 
> static int srat_bypass_bios;
> 
> Don't need to init to 0.

I'll fix and send a second version.  Thanks Randy.

-PJ
