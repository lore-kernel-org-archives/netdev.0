From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for February 3 (netfilter)
Date: Fri, 4 Feb 2011 11:34:26 -0800
Message-ID: <20110204113426.5d59522b.randy.dunlap@oracle.com>
References: <20110203160034.44ae3247.sfr@canb.auug.org.au>
	<20110204111511.1f4d6706.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110204111511.1f4d6706.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2011 11:15:11 -0800 Randy Dunlap wrote:

> On Thu, 3 Feb 2011 16:00:34 +1100 Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > Changes since 20110202:

Oops.  This build error is in 20110204, not Feb. 3.


> When SYSCTL and PROC_FS and NETFILTER_NETLINK are not enabled:
> 
> net/built-in.o: In function `try_to_load_type':
> ip_set_core.c:(.text+0x3ab49): undefined reference to `nfnl_unlock'
> ip_set_core.c:(.text+0x3ab4e): undefined reference to `nfnl_lock'
> net/built-in.o: In function `ip_set_nfnl_put':
> (.text+0x3ab6c): undefined reference to `nfnl_lock'
> net/built-in.o: In function `ip_set_nfnl_put':
> (.text+0x3ab87): undefined reference to `nfnl_unlock'
> net/built-in.o: In function `ip_set_nfnl_get_byindex':
> (.text+0x3abb1): undefined reference to `nfnl_lock'
> net/built-in.o: In function `ip_set_nfnl_get_byindex':
> (.text+0x3abc8): undefined reference to `nfnl_unlock'
> net/built-in.o: In function `ip_set_nfnl_get':
> (.text+0x3abef): undefined reference to `nfnl_lock'
> net/built-in.o: In function `ip_set_nfnl_get':
> (.text+0x3ac00): undefined reference to `nfnl_unlock'
> net/built-in.o: In function `ip_set_sockfn_get':
> ip_set_core.c:(.text+0x3b3a8): undefined reference to `nfnl_lock'
> ip_set_core.c:(.text+0x3b3d0): undefined reference to `nfnl_unlock'
> ip_set_core.c:(.text+0x3b403): undefined reference to `nfnl_lock'
> ip_set_core.c:(.text+0x3b414): undefined reference to `nfnl_unlock'
> net/built-in.o: In function `ip_set_init':
> ip_set_core.c:(.init.text+0xe40): undefined reference to `nfnetlink_subsys_register'
> ip_set_core.c:(.init.text+0xe60): undefined reference to `nfnetlink_subsys_unregister'
> net/built-in.o: In function `ip_set_fini':
> ip_set_core.c:(.exit.text+0x1b2): undefined reference to `nfnetlink_subsys_unregister'
> 
> 
> Full .config file is attached.
> 
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
