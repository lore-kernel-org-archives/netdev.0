From: Nick Desaulniers <ndesaulniers@google.com>
Subject: Re: [PATCH v2] netfilter: nf_nat_h323: fix logical-not-parentheses warning
Date: Mon, 14 Aug 2017 10:36:03 -0700
Message-ID: <CAKwvOdmw+bnN-nKeKbE8WJJ8Enc4PCeC3KD5KpaSVOT4+ycDKQ@mail.gmail.com>
References: <20170811174259.GA3743@salvia> <20170811181607.33878-1-ndesaulniers@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthias Kaehlcke <mka@chromium.org>,
        Lorenzo Colitti <lorenzo@google.com>,
        Nick Desaulniers <ndesaulniers@google.com>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170811181607.33878-1-ndesaulniers@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor nit for the commit message that can get fixed up when being merged:

On Fri, Aug 11, 2017 at 11:16 AM, Nick Desaulniers
<ndesaulniers@google.com> wrote:

> if (x)
>   return
> ...
>
> rather than:
>
> if (!x == 0)

should remove the `!`, ex:

if (x == 0)

>   ...
> else
>   return

-- 
Thanks,
~Nick Desaulniers
