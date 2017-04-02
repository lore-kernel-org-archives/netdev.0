From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: fix build error with devlink build
 as module
Date: Sat, 01 Apr 2017 20:11:01 -0700 (PDT)
Message-ID: <20170401.201101.1392581874133981603.davem@davemloft.net>
References: <20170331094452.32578-1-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tobias.regnery@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331094452.32578-1-tobias.regnery@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Fri, 31 Mar 2017 11:44:52 +0200

> After commit 96567d5dacf4 ("net: dsa: dsa2: Add basic support of devlink")
> I see the following link error with CONFIG_NET_DSA=y and CONFIG_NET_DEVLINK=m:
> 
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe226b): undefined reference to `devlink_alloc'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe2284): undefined reference to `devlink_register'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe243e): undefined reference to `devlink_port_register'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe24e1): undefined reference to `devlink_port_register'
> net/built-in.o: In function 'dsa_register_switch':
> (.text+0xe24fa): undefined reference to `devlink_port_type_eth_set'
> net/built-in.o: In function 'dsa_dst_unapply.part.8':
> dsa2.c:(.text.unlikely+0x345): undefined reference to 'devlink_port_unregister'
> dsa2.c:(.text.unlikely+0x36c): undefined reference to 'devlink_port_unregister'
> dsa2.c:(.text.unlikely+0x38e): undefined reference to 'devlink_port_unregister'
> dsa2.c:(.text.unlikely+0x3f2): undefined reference to 'devlink_unregister'
> dsa2.c:(.text.unlikely+0x3fb): undefined reference to 'devlink_free'
> 
> Fix this by adding a dependency on MAY_USE_DEVLINK so that CONFIG_NET_DSA
> get switched to be build as module when CONFIG_NET_DEVLINK=m.
> 
> Fixes: 96567d5dacf4 ("net: dsa: dsa2: Add basic support of devlink")
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>

Applied.
