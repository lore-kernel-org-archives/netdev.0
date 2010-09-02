From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Thu, 2 Sep 2010 12:03:08 +0200
Message-ID: <20100902100308.GA17167@basil.fritz.box>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
 <20100902065731.GB29972@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org, andi@firstfloor.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100902065731.GB29972@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This isnt a particularly useful solution to users of said systems - they 
> have to figure out that this option exists, and then they have to enter 
> this option on the boot line.

This usually only happens in early preproduction systems. So far
the BIOS always got fixed before they shipped to users.

But it's still useful to have this option so that the early
users have a workaround.

It's difficult to maintain DMI strings for early systems,
they are too bleeding edge and the entries would be stale
as soon as the BIOS is fixed.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
