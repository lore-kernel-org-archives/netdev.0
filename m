From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_hashlimit: Enhance the xt_hashlimit to
 avoid duplicated codes
Date: Tue, 21 Oct 2014 17:31:28 +0200
Message-ID: <20141021153128.GA3657@salvia>
References: <CA+6hz4o-2vSEzH+hjYAUfWRVqHQ3QfcCr8q11eoRpCTq2uTYtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	davem@davemloft.net,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Feng Gao <gfree.wind@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+6hz4o-2vSEzH+hjYAUfWRVqHQ3QfcCr8q11eoRpCTq2uTYtg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 21, 2014 at 11:23:16PM +0800, Feng Gao wrote:
> Hi all,
> 
> Enhance the functions "dsthash_alloc_init" and "hashlimit_mt" in file
> "xt_hashlimit.c" to avoid two duplicated codes following:
> 
> -           dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
> -           rateinfo_recalc(dh, now, hinfo->cfg.mode);
> 
> 
> The whole patch is following

The patch seems mangled by your MUA.

BTW, you can just Cc netfilter patches to
netfilter-devel@vger.kernel.org. No need to Cc that many people.

