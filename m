From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Fri, 3 Sep 2010 08:39:34 +0200
Message-ID: <20100903063934.GA25863@elte.hu>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
 <20100902065731.GB29972@elte.hu>
 <20100902100308.GA17167@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100902100308.GA17167@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andi Kleen <andi@firstfloor.org> wrote:

> > This isnt a particularly useful solution to users of said systems - 
> > they have to figure out that this option exists, and then they have 
> > to enter this option on the boot line.
> 
> This usually only happens in early preproduction systems. So far the 
> BIOS always got fixed before they shipped to users.

'Usually' != 'always'. Read the changelog:

  ' There are BIOSes in production that have these failures, so this will 
    allow people in the field to work around these BIOS issues. '

Peter, which system in production that has this problem? That one needs 
a DMI match.

Preproduction systems can certainly be hacked around with the boot 
option and are not worth the DMI match. (preproduction systems also tend 
to have have very unspecific DMI strings in most cases - things like 
'1234567890' or 'to be filled by OEM')

In important cases a PCI ID match can be done for serious bugs in 
widespread preproduction systems - we have a handful of examples in-tree 
for such workarounds - but i doubt this is such a case - we use it for 
crasher bugs, not for 'boots up slow' cases.

Nevertheless, production systems need a DMI match.

Thanks,

	Ingo
