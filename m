From: Ingo Molnar <mingo@elte.hu>
Subject: Re: linux-next: Tree for January 8 (net/ip.h, BUG=n)
Date: Wed, 13 Jan 2010 08:35:40 +0100
Message-ID: <20100113073540.GA30577@elte.hu>
References: <20100108164232.d3e1a164.sfr@canb.auug.org.au>
 <20100108092505.4f4e1ac3.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100108092505.4f4e1ac3.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Fri, 8 Jan 2010 16:42:32 +1100 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20100107:
> 
> 
> When CONFIG_BUG=n, CONFIG_GENERIC_BUG=n:
> 
> include/net/ip.h:341: error: implicit declaration of function '__WARN'
> 
> This affects:
> make[3]: *** [security/selinux/hooks.o] Error 1
> make[3]: *** [fs/ceph/messenger.o] Error 1
> make[3]: *** [net/core/sock.o] Error 1
> make[4]: *** [drivers/net/benet/be_main.o] Error 1

FYI, this new build bug is now upstream and triggers in -tip testing as well.

	Ingo
