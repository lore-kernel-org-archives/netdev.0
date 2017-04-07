From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] net: netfilter:Remove exceptional & on function name
Date: Fri, 7 Apr 2017 18:28:33 +0200
Message-ID: <20170407162833.GA10487@salvia>
References: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 02, 2017 at 02:52:12PM +0530, Arushi Singhal wrote:
> Remove & from function pointers to conform to the style found elsewhere
> in the file. Done using the following semantic patch
> 
> // <smpl>
> @r@
> identifier f;
> @@
> 
> f(...) { ... }
> @@
> identifier r.f;
> @@
> 
> - &f
> + f
> // </smpl>

I have collapsed these four patches.

You only need to send one patch per logical update.

I also detected that you missed one spot in nft_hash.c, I manually
updated this but next time you have to be more careful.

Thanks!
