From: Adrian Bunk <bunk@stusta.de>
Subject: netfilter: IP_NF_CONNTRACK_NETLINK=y, IP_NF_NAT=m compile error
Date: Sat, 1 Apr 2006 11:18:47 +0200
Message-ID: <20060401091847.GC28310@stusta.de>
References: <Pine.LNX.4.64.0603192216450.3622@g5.osdl.org> <20060328163932.GJ28030@miggy.org> <20060331170916.GL28030@miggy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750920AbWDAJSu@vger.kernel.org>
To: Athanasius <link@miggy.org>, Linus Torvalds <torvalds@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	coreteam@netfilter.org
Content-Disposition: inline
In-Reply-To: <20060331170916.GL28030@miggy.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 31, 2006 at 06:09:16PM +0100, Athanasius wrote:
> On Tue, Mar 28, 2006 at 05:39:32PM +0100, Athanasius wrote:
> >   CC      init/version.o
> >   LD      init/built-in.o
> >   LD      .tmp_vmlinux1
> > net/built-in.o(.text+0x7c990): In function `ctnetlink_parse_nat_proto':
> > : undefined reference to `ip_nat_proto_find_get'
> > net/built-in.o(.text+0x7c9b2): In function `ctnetlink_parse_nat_proto':
> > : undefined reference to `ip_nat_proto_put'
> > net/built-in.o(.text+0x7d695): In function `ctnetlink_change_conntrack':
> > : undefined reference to `ip_nat_setup_info'
> > net/built-in.o(.text+0x7da9f): In function `ctnetlink_create_conntrack':
> > : undefined reference to `ip_nat_setup_info'
> > make: *** [.tmp_vmlinux1] Error 1
> ...
> > CONFIG_IP_NF_TARGET_TCPMSS=m
> > CONFIG_IP_NF_NAT=m
> > CONFIG_IP_NF_NAT_NEEDED=y
> > CONFIG_IP_NF_TARGET_MASQUERADE=m
> 
> ...
> 
>   It looks like the problem was that "CONFIG_IP_NF_NAT=m".  I changed
> this to 'y' and things look to be compiling fine now.
>...

First of all thanks for your report.

More exactly, it's the combination CONFIG_IP_NF_CONNTRACK_NETLINK=y, 
CONFIG_IP_NF_NAT=m.

Can someone who understands the netfilter dependencies please look into 
this bug?

It's present in both 2.6.16.1 and 2.6.16-mm2.
 
> -Ath

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
