From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Fri, 3 Sep 2010 12:04:49 +0200
Message-ID: <20100903120449.3d177e04@basil.nowhere.org>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
	<41621.148.87.67.139.1283378664.squirrel@www.xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <41621.148.87.67.139.1283378664.squirrel@www.xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > +int srat_bypass_bios = 0;
> 
> static int srat_bypass_bios;
> 
> Don't need to init to 0.

It actually doesn't matter to gcc, it generates the same
code for both cases.

-Andi
