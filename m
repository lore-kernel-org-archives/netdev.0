From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre6: add Kconfig dependency for NET_IPGRE_DEMUX
Date: Wed, 04 May 2016 14:12:54 -0400 (EDT)
Message-ID: <20160504.141254.2216695965556907500.davem@davemloft.net>
References: <1462288817-721172-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, tom@herbertland.com, hakke_007@gmx.de,
	pabeni@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462288817-721172-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  3 May 2016 17:19:57 +0200

> The ipv6 gre implementation was cleaned up to share more code
> with the ipv4 version, but it can be enabled even when NET_IPGRE_DEMUX
> is disabled, resulting in a link error:
> 
> net/built-in.o: In function `gre_rcv':
> :(.text+0x17f5d0): undefined reference to `gre_parse_header'
> ERROR: "gre_parse_header" [net/ipv6/ip6_gre.ko] undefined!
> 
> This adds a Kconfig dependency to prevent that now invalid
> configuration.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 308edfdf1563 ("gre6: Cleanup GREv6 receive path, call common GRE functions")

Applied, thanks.
