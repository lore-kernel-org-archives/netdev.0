From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [Linaro-acpi] [V2 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Thu, 07 May 2015 22:18:44 +0200
Message-ID: <4260574.bvpyYkBNGq@vostro.rjw.lan>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com> <554A92C3.7060606@amd.com> <2842267.oTDe4myPcU@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: linaro-acpi@lists.linaro.org,
	Suravee Suthikulanit <suravee.suthikulpanit@amd.com>,
	herbert@gondor.apana.org.au, catalin.marinas@arm.com,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-acpi@vger.kernel.org,
	netdev@vger.kernel.org,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lenb@kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2842267.oTDe4myPcU@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, May 07, 2015 11:07:08 AM Arnd Bergmann wrote:
> On Wednesday 06 May 2015 17:16:35 Suravee Suthikulanit wrote:
> > On 5/6/2015 5:21 PM, Rafael J. Wysocki wrote:
> > >>>> > >>+      bool
> > >>>> > >>+
> > >>>> > >>+config ACPI_SUPPORT_CCA_ZERO
> > >>> > >
> > >>> > >I guess this means "we support devices that can DMA, but are not coherent".
> > >>> > >right?
> > >> >
> > >> >Yes, basically when _CCA=0.
> > > So what about
> > >
> > >       ARCH_SUPPORT_CACHE_INCOHERENT_DMA
> > 
> > Since this is specific to ACPI _CCA, I just want to be clear with the 
> > naming.
> 
> How about directly using the architecture names here, this is inherently
> architecture specific, and it's more likely that if another architecture
> gets added in the future that it will have other requirements.

Sounds reasonable to me.

Rafael
