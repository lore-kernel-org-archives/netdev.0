From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2] atomics,cmpxchg: Privatize the inclusion of
 asm/cmpxchg.h
Date: Tue, 8 Sep 2015 21:00:32 -0700
Message-ID: <20150909040032.GB5497@kroah.com>
References: <1441762024-2081-1-git-send-email-boqun.feng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Will Deacon <will.deacon@arm.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Shradha Shah <sshah@solarflare.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	William Hubbs <w.d.hubbs@gmail.com>,
	Chris Brannon <chris@the-brannons.com>,
	Kirk Reiser <kirk@reisers.ca>,
	Samuel Thibault <samuel.thibault@ens-lyon.org>,
	Aybuke Ozdemir <aybuke.147@gmail.com>,
	Davidlohr Bueso <dave@stgolabs.net>,
	linux-net-drivers@solarflare.com, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org, speakup@linux-speakup.org,
	devel@driverdev.osuosl.org
To: Boqun Feng <boqun.feng@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441762024-2081-1-git-send-email-boqun.feng@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09, 2015 at 09:27:04AM +0800, Boqun Feng wrote:
> After commit:
> 
> atomics: add acquire/release/relaxed variants of some atomic operations
> 
> Architectures may only provide {cmp,}xchg_relaxed definitions in
> asm/cmpxchg.h. Other variants, such as {cmp,}xchg, may be built in
> linux/atomic.h, which means simply including asm/cmpxchg.h may not get
> the definitions of all the{cmp,}xchg variants. Therefore, we should
> privatize the inclusions of asm/cmpxchg.h to keep it only included in
> arch/* and replace the inclusions outside with linux/atomic.h
> 
> Acked-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Boqun Feng <boqun.feng@gmail.com>
> ---
> v1 --> v2:
> 	1. rebase on current master branch of tip tree
> 	2. remove documentation modification
> 

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

