From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] nfnetlink_log: Use GFP_NOWARN for skb allocation
Date: Fri, 21 Oct 2016 12:38:47 +0200
Message-ID: <20161021103847.GB2118@salvia>
References: <1b50152e3ea7c3e18995349126d4352e4fc73933.1475873569.git.calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-team@fb.com
To: Calvin Owens <calvinowens@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1b50152e3ea7c3e18995349126d4352e4fc73933.1475873569.git.calvinowens@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 07, 2016 at 02:02:16PM -0700, Calvin Owens wrote:
> Since the code explicilty falls back to a smaller allocation when the
> large one fails, we shouldn't complain when that happens.

Applied, thanks.
