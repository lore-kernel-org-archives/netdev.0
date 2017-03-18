From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Sun, 19 Mar 2017 00:47:59 +0800
Message-ID: <20170318164759.GA23837@gondor.apana.org.au>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: elena.reshetova@intel.com, davem@davemloft.net,
        keescook@chromium.org, peterz@infradead.org,
        netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, stephen@networkplumber.org,
        ishkamiel@gmail.com, dwindsor@gmail.com,
        Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2017-03-17 at 07:42 +0000, Reshetova, Elena wrote:
> 
>> Should we then first measure the actual numbers to understand what we
>> are talking here about? 
>> I would be glad to do it if you suggest what is the correct way to do
>> measurements here to actually reflect the real life use cases. 
> 
> How have these patches been tested in real life exactly ?
> 
> Can you quantify number of added cycles per TCP packet, where I expect
> we have maybe 20 atomic operations in all layers ...

I completely agree.  I think this thing needs to default to the
existing atomic_t behaviour.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
