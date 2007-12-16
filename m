From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Sun, 16 Dec 2007 09:58:18 +0100
Message-ID: <20071216085818.GA27280@elte.hu>
References: <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au> <20071215135851.GA29063@gondor.apana.org.au> <20071215184327.GA21434@elte.hu> <20071216023621.GB959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762557AbXLPI67@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071216023621.GB959@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Dec 15, 2007 at 07:43:28PM +0100, Ingo Molnar wrote:
> >
> > we could perhaps introduce stat_smp_processor_id(), which signals that 
> > the CPU id is used for statistical purposes and does not have to be 
> > exact? In any case, your patch looks good too.
> 
> Unfortunately that doesn't work because we can then have two CPUs 
> trying to update the same counter which may corrupt it.

ah, indeed. I missed that correctness aspect of your patch. Good catch!

	Ingo
