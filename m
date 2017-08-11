From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_nat_h323: fix logical-not-parentheses
 warning
Date: Fri, 11 Aug 2017 19:42:59 +0200
Message-ID: <20170811174259.GA3743@salvia>
References: <20170731183949.73763-1-ndesaulniers@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mka@chromium.org, lorenzo@google.com,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nick Desaulniers <ndesaulniers@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731183949.73763-1-ndesaulniers@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nick,

On Mon, Jul 31, 2017 at 11:39:49AM -0700, Nick Desaulniers wrote:
> Clang produces the following warning:
[...]
> Also, it's even cleaner to use the form:
> 
> if (x)
> 
> but then if the return codes change from treating 0 as success (unlikely),
> then all call sites must be updated.
> 
> I'm happy to send v2 that changes to that form, and updates the other call
> sites to be:
> 
> if (set_h225_addr())
>   handle_failures()
> else
>   handle_success()

That sounds very reasonable, send a v2 if this triggers a larger
patch.

Or I can just take this patch, as you prefer.

Thanks!
