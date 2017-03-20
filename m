From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] [netfilter-next] netfilter: remove unused refcount
 variable
Date: Mon, 20 Mar 2017 13:56:57 +0100
Message-ID: <20170320125657.GA12690@salvia>
References: <20170320123708.4025261-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Liping Zhang <liping.zhang@spreadtrum.com>,
        David Windsor <dwindsor@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Phil Turnbull <phil.turnbull@oracle.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170320123708.4025261-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 01:37:01PM +0100, Arnd Bergmann wrote:
> The refcount variable was accidentally introduced without any reference
> to it. Removing it again avoids this warning:
> 
> net/netfilter/nfnetlink_acct.c: In function 'nfnl_acct_try_del':
> net/netfilter/nfnetlink_acct.c:329:15: error: unused variable 'refcount' [-Werror=unused-variable]

Thanks Arnd. Elena already fixed it here:

https://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git/commit/
