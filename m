From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH] x86: remove vmalloc.h from asm/io.h
Date: Fri, 29 May 2015 11:21:05 +0200
Message-ID: <20150529092105.GA30603@gmail.com>
References: <20150529191847.2d4cb3a7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Anton Vorontsov <anton@enomsg.org>,
	Colin Cross <ccross@android.com>,
	Kees Cook <keescook@chromium.org>,
	Tony Luck <tony.luck@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <lenb@kernel.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Vinod Koul <vinod.koul@intel.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Hiral Patel <hiralpat@cisco.com>,
	Suma Ramars <sramars@cisco.com>,
	Brian Uchino <buchino@cisco.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.d
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150529191847.2d4cb3a7@canb.auug.org.au>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Nothing in asm/io.h uses anything from vmalloc.h, so remove the include
> and fix up the build problems in an allmodconfig (64 bit and 32 bit)
> build.
> 
> This may be the place where x86 builds get vmalloc.h implicitly included
> and that tends to hide places where vmalloc() et al are added to files
> but the include of vmalloc.h is forgotten.

Good idea.

Acked-by: Ingo Molnar <mingo@kernel.org>

> Based in Linus' tree of today.
> 
> There are probably more places that need vmalloc.h included, but this passes 64 
> bit and 32 bit allmodconfig builds, so is a place to start.

Please also test x86 allnoconfig and defconfig 32/64, that tends to unearth the 
remaining places. People doing randconfig testing will find the rest.

Thanks,

	Ingo
