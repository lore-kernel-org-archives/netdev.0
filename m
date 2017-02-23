From: Florian Westphal <fw@strlen.de>
Subject: Re: netfilter: nft_ct: add zone id set support
Date: Thu, 23 Feb 2017 12:34:35 +0100
Message-ID: <20170223113435.GF11144@breakpoint.cc>
References: <20170222190219.EC87B661B65@gitolite.kernel.org>
 <CAMuHMdUJ=2+9ko0KEU7rX3rb7vghNj3Xc-HSLSK=-kqQ+CZM6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdUJ=2+9ko0KEU7rX3rb7vghNj3Xc-HSLSK=-kqQ+CZM6w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> On Wed, Feb 22, 2017 at 8:02 PM, Linux Kernel Mailing List
> <linux-kernel@vger.kernel.org> wrote:
> > Web:        https://git.kernel.org/torvalds/c/edee4f1e92458299505ff007733f676b00c516a1
> > Commit:     edee4f1e92458299505ff007733f676b00c516a1
> > Parent:     5c178d81b69f08ca3195427a6ea9a46d9af23127
> > Refname:    refs/heads/master
> > Author:     Florian Westphal <fw@strlen.de>
> > AuthorDate: Fri Feb 3 13:35:50 2017 +0100
> > Committer:  Pablo Neira Ayuso <pablo@netfilter.org>
> > CommitDate: Wed Feb 8 14:16:23 2017 +0100
> >
> Unlike for the other cases of the switch statement, "len" is not initialized
> here...
> 
> > +               break;
> >         priv->sreg = nft_parse_register(tb[NFTA_CT_SREG]);
> >         err = nft_validate_register_load(priv->sreg, len);
> 
> ... and used here, which may lead to spurious failures of
> nft_validate_register_load().

Yes, Dan reported this and a patch is queued at
http://patchwork.ozlabs.org/patch/727573/

Pablo, any reason why this is still waiting?
Do you want me to run more tests?
