From: Adrian Bunk <bunk@fs.tum.de>
Subject: 2.6: DECNET compile errors with SYSCTL=n
Date: Thu, 12 Aug 2004 00:40:15 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040811224015.GP26174@fs.tum.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268285AbUHKWk1@vger.kernel.org>
To: Steve Whitehouse <SteveW@ACM.org>,
	Eduardo Marcelo Serrat <emserrat@geocities.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

I'm getting the following compile errors in 2.6.8-rc4-mm1 (but it 
doesn't seem to be specific to -mm) with CONFIG_SYSCTL=n:

<--  snip  -->

...
  LD      .tmp_vmlinux1
net/built-in.o(.text+0x1685e9): In function `dn_route_output_slow':
: undefined reference to `dn_dev_get_default'
net/built-in.o(.text+0x16a749): In function `dn_dev_bind_default':
: undefined reference to `dn_dev_get_default'
net/built-in.o(.text+0x16a85b): In function `dn_send_endnode_hello':
: undefined reference to `mtu2blksize'
net/built-in.o(.text+0x16a9f2): In function `dn_send_router_hello':
: undefined reference to `mtu2blksize'
net/built-in.o(.text+0x16aa08): In function `dn_send_router_hello':
: undefined reference to `mtu2blksize'
net/built-in.o(.text+0x16aaeb): In function `dn_send_router_hello':
: undefined reference to `mtu2blksize'
net/built-in.o(.text+0x16b1a4): In function `dn_dev_up':
: undefined reference to `dn_dev_set_default'
net/built-in.o(.text+0x16b1e8): In function `dn_dev_delete':
: undefined reference to `dn_dev_check_default'
net/built-in.o(.text+0x16b6b8): In function `dn_dev_seq_show':
: undefined reference to `mtu2blksize'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
