From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: A reduced Linux network stack for small systems
Date: Tue, 6 May 2014 09:18:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F70CFB5@AcuExch.aculab.com>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tom.zanussi@linux.intel.com" <tom.zanussi@linux.intel.com>
To: 'Andi Kleen' <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen
> There has been a lot of interest recently to run Linux on very small systems,
> like Quark systems. These may have only 2-4MB memory. They are also limited
> by flash space.

I'm intrigued about the 2-4MB memory.
That is more that would typically be available on-chip in a DSP or FPGA.
It sounds like an expensive SRAM chip.
OTOH a single SDRAM gives 16MB and DDR a lot more - and are a lot cheaper
and lower power.
Most modern silicon can easily have SDRAM/DDR interfaces.

You may want some size reduction to run in 16MB, but it is not as problematic
as running in 2MB.

With that little memory I wouldn't want to run anything that relied on
dynamic memory allocation (after startup) - except for fixed size data
buffers.

	David
