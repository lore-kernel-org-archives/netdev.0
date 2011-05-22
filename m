From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add missing prefetch.h include
Date: Sun, 22 May 2011 18:15:30 -0400 (EDT)
Message-ID: <20110522.181530.2048359124881166038.davem@davemloft.net>
References: <20110522165510.GB2504@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: heiko.carstens@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110522165510.GB2504@osiris.boeblingen.de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Sun, 22 May 2011 18:55:10 +0200

> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Fixes build errors on s390 and probably other archs as well:
> 
> In file included from net/ipv4/ip_forward.c:32:0:
> include/net/udp.h: In function 'udp_csum_outgoing':
> include/net/udp.h:141:2: error: implicit declaration of function 'prefetch'
> 
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

No, as Linus pointed out, he will just remove these prefetches
in here, they should just be removed.
