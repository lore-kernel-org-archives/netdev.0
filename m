From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 0/4] improve fault-tolerance of rhashtable runtime-test
Date: Mon, 30 Nov 2015 17:37:55 +0800
Message-ID: <20151130093755.GA8159@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448039840-11367-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Sutter <phil@nwl.cc> wrote:
> The following series aims to improve lib/test_rhashtable in different
> situations:
> 
> Patch 1 allows the kernel to reschedule so the test does not block too
>        long on slow systems.
> Patch 2 fixes behaviour under pressure, retrying inserts in non-permanent
>        error case (-EBUSY).
> Patch 3 auto-adjusts the upper table size limit according to the number
>        of threads (in concurrency test). In fact, the current default is
>        already too small.
> Patch 4 makes it possible to retry inserts even in supposedly permanent
>        error case (-ENOMEM) to expose rhashtable's remaining problem of
>        -ENOMEM being not as permanent as it is expected to be.

I'm sorry but this patch series is simply bogus.

If rhashtable is indeed returning such errors under normal
conditions then rhashtable is broken and we must fix it instead
of working around it in the test code!

FWIW I still haven't been able to reproduce this problem, perhaps
because my machines have too few CPUs?

So can someone please help me reproduce this? Because just loading
test_rhashtable isn't doing it.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
