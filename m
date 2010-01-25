From: Borislav Petkov <borislav.petkov@amd.com>
Subject: Re: [PATCH 8/8] percpu: add __percpu sparse annotations to what's
 left
Date: Mon, 25 Jan 2010 16:54:08 +0100
Message-ID: <20100125155408.GF14274@aftab>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
 <1264432935-10453-9-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, fweisbec@gmail.com, dan.j.williams@intel.com,
	ying.huang@intel.com, lenb@kernel.org, neilb@suse.de,
	cl@linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753993Ab0AYPyY@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1264432935-10453-9-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 12:22:15AM +0900, Tejun Heo wrote:
> Add __percpu sparse annotations to places which didn't make it in one
> of the previous patches.  All converions are trivial.
> 
> These annotations are to make sparse consider percpu variables to be
> in a different address space and warn if accessed without going
> through percpu accessors.  This patch doesn't affect normal builds.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Borislav Petkov <borislav.petkov@amd.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Len Brown <lenb@kernel.org>
> Cc: Neil Brown <neilb@suse.de>
> ---
>  crypto/cryptd.c                  |    2 +-
>  drivers/acpi/processor_perflib.c |    2 +-
>  drivers/dma/dmaengine.c          |    2 +-
>  drivers/edac/amd64_edac.c        |    2 +-

For the edac bits:

Acked-by: Borislav Petkov <borislav.petkov@amd.com>

-- 
Regards/Gruss,
Boris.

--
Advanced Micro Devices, Inc.
Operating Systems Research Center
