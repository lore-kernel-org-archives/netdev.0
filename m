From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Linaro-acpi] [V2 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Thu, 07 May 2015 11:07:08 +0200
Message-ID: <2842267.oTDe4myPcU@wuerfel>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com> <4573209.dHyztuCFMt@vostro.rjw.lan> <554A92C3.7060606@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	herbert@gondor.apana.org.au, catalin.marinas@arm.com,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lenb@kernel.org
To: linaro-acpi@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <554A92C3.7060606@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 06 May 2015 17:16:35 Suravee Suthikulanit wrote:
> On 5/6/2015 5:21 PM, Rafael J. Wysocki wrote:
> >>>> > >>+      bool
> >>>> > >>+
> >>>> > >>+config ACPI_SUPPORT_CCA_ZERO
> >>> > >
> >>> > >I guess this means "we support devices that can DMA, but are not coherent".
> >>> > >right?
> >> >
> >> >Yes, basically when _CCA=0.
> > So what about
> >
> >       ARCH_SUPPORT_CACHE_INCOHERENT_DMA
> 
> Since this is specific to ACPI _CCA, I just want to be clear with the 
> naming.

How about directly using the architecture names here, this is inherently
architecture specific, and it's more likely that if another architecture
gets added in the future that it will have other requirements.

	Arnd
