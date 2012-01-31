From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [00/22] Cyclades PC300 driver: summary of patch series
Date: Tue, 31 Jan 2012 20:20:30 +0100
Message-ID: <m3d39z3cht.fsf@intrepid.localdomain>
References: <20120130024243.GA10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, mmarek@suse.cz, jkosina@suse.cz,
	joe@perches.com, justinmattock@gmail.com, gregkh@suse.de,
	alan@linux.intel.com, jdmason@kudzu.us
To: Andrea Shepard <andrea@persephoneslair.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120130024243.GA10262@cronus.persephoneslair.org> (Andrea
	Shepard's message of "Sun, 29 Jan 2012 18:42:43 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrea Shepard <andrea@persephoneslair.org> writes:

> The Cyclades PC-300 is a line of PCI synchronous serial cards, which was
> produced in single and dual port models with either T1/E1 or V.35 ports.
> It used a Hitachi HD64572 (SCA-II) synchronous serial chip, and in the
> T1/E1 models an Infineon FALC-LH line interface/framing chip.  Copies
> of the hardware documentation may be found at [1].

BTW the V.35/V.24/X.21 version (i.e. non-T1/E1) are supported by the
pc300too.c driver. Or at least they're supposed to, I admit I haven't
used this kind of hw for several years (but can still test and fix, when
time permits).

Perhaps, just perhaps, merging T1/E1 support into pc300too.c would be
a better idea than dealing with Cyclades' old code.

The pc300too shares common SCA-II code with a driver for another hw,
pci200syn. I think it's been verified to work on non-x86-32 systems.

Esp. given this:

>  * Patches 01 through 16 merge in version 4.1.0, and fix build, portability
>    and style problems.  As of patch 16, the driver will build cleanly and
>    will detect hardware, but not operate reliably.
-- 
Krzysztof Halasa
