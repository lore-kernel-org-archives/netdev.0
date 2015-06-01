From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] x86: remove vmalloc.h from asm/io.h
Date: Mon, 01 Jun 2015 15:59:31 -0700 (PDT)
Message-ID: <20150601.155931.1230241015446814769.davem@davemloft.net>
References: <20150529191847.2d4cb3a7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com,
	x86@kernel.org, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, anton@enomsg.org, ccross@android.com,
	keescook@chromium.org, tony.luck@intel.com, rjw@rjwysocki.net,
	lenb@kernel.org, kristen@linux.intel.com, viresh.kumar@linaro.org,
	vinod.koul@intel.com, kys@microsoft.com, haiyangz@microsoft.com,
	hiralpat@cisco.com, sramars@cisco.com, buchino@cisco.com,
	JBottomley@odin.com, perex@perex.cz, tiwai@suse.de,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org,
	linux-pm@vger.kernel.org, dmaengine@vger.kernel.org,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, alsa-devel@alsa-project.org
To: sfr@canb.auug.org.au
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20150529191847.2d4cb3a7@canb.auug.org.au>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 29 May 2015 19:18:47 +1000

> Nothing in asm/io.h uses anything from vmalloc.h, so remove the include
> and fix up the build problems in an allmodconfig (64 bit and 32 bit)
> build.
> 
> This may be the place where x86 builds get vmalloc.h implicitly included
> and that tends to hide places where vmalloc() et al are added to files
> but the include of vmalloc.h is forgotten.
> 
 ...
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

With the follow-on allnoconfig fixes:

Acked-by: David S. Miller <davem@davemloft.net>

Thanks a lot for doing this!
