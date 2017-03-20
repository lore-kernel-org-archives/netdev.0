From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 14:23:57 +0100
Message-ID: <20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170318164759.GA23837@gondor.apana.org.au>
 <20170318.182121.439615057765380575.davem@davemloft.net>
 <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
 <20170320131629.GA26405@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        elena.reshetova@intel.com, keescook@chromium.org,
        netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, stephen@networkplumber.org,
        ishkamiel@gmail.com, dwindsor@gmail.com, akpm@linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170320131629.GA26405@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 09:16:29PM +0800, Herbert Xu wrote:
> On Mon, Mar 20, 2017 at 11:39:37AM +0100, Peter Zijlstra wrote:
> >
> > Can we at least give a benchmark and have someone run numbers? We should
> > be able to quantify these things.
> 
> Do you realise how many times this thing gets hit at 10Gb/s or
> higher? Anyway, since you're proposing this change you should
> demonstrate that it does not cause a performance regression.

So what bench/setup do you want ran?
