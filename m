From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net:netfilter alloc xt_byteslimit_htable with wrong size
Date: Fri, 8 Sep 2017 13:58:39 +0200
Message-ID: <20170908115839.GA14561@salvia>
References: <1504839616-14519-1-git-send-email-zhizhou.tian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kadlec@blackhole.kfki.hu, fw@strlen.de, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: zhizhou.tian@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1504839616-14519-1-git-send-email-zhizhou.tian@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 08, 2017 at 11:00:16AM +0800, zhizhou.tian@gmail.com wrote:
> From: Zhizhou Tian <zhizhou.tian@gmail.com>
> 
> struct xt_byteslimit_htable used hlist_head,
> but alloc memory with sizeof(struct list_head)

Applied, thanks.

For the record, I have mangled the patch titled to:

        netfilter: xt_hashlimit: alloc hashtable with right size
