From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] netfilter: nf_nat_h323: fix logical-not-parentheses
 warning
Date: Thu, 24 Aug 2017 18:49:37 +0200
Message-ID: <20170824164937.GA14949@salvia>
References: <20170811174259.GA3743@salvia>
 <20170811181607.33878-1-ndesaulniers@google.com>
 <CAKwvOdmw+bnN-nKeKbE8WJJ8Enc4PCeC3KD5KpaSVOT4+ycDKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias Kaehlcke <mka@chromium.org>,
        Lorenzo Colitti <lorenzo@google.com>,
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
In-Reply-To: <CAKwvOdmw+bnN-nKeKbE8WJJ8Enc4PCeC3KD5KpaSVOT4+ycDKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2017 at 10:36:03AM -0700, Nick Desaulniers wrote:
> Minor nit for the commit message that can get fixed up when being merged:
> 
> On Fri, Aug 11, 2017 at 11:16 AM, Nick Desaulniers
> <ndesaulniers@google.com> wrote:
> 
> > if (x)
> >   return
> > ...
> >
> > rather than:
> >
> > if (!x == 0)
> 
> should remove the `!`, ex:
> 
> if (x == 0)

Amended this here, and applied. Thanks!
