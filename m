From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [BUILD_FAILURE] linux-next: 20081125 - 8390 network driver build
 fails
Date: Tue, 25 Nov 2008 10:39:09 -0800
Message-ID: <492C464D.4080704@oracle.com>
References: <20081125213738.881b425e.sfr@canb.auug.org.au> <20081125182542.GA4914@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org, mel@csn.ul.ie
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20081125182542.GA4914@linux.vnet.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kamalesh Babulal wrote:
> Hi Stephen,
> 
> 	allyesconfig build of next-20081125 kernel over x86_32 box fails with
> error message.
> 
> drivers/net/8390p.o: In function `ei_get_stats':
> /usr/local/autobench/autotest/tmp/build/linux/drivers/net/lib8390.c:889: multiple definition of `ei_get_stats'
> drivers/net/8390.o:/usr/local/autobench/var/tmp/build/linux/drivers/net/lib8390.c:889: first defined here
> ld: Warning: size of symbol `ei_get_stats' changed from 106 in drivers/net/8390.o to 148 in drivers/net/8390p.o
> drivers/net/8390p.o: In function `ei_start_xmit':
> /usr/local/autobench/autotest/tmp/build/linux/drivers/net/lib8390.c:310: multiple definition of `ei_start_xmit'
> drivers/net/8390.o:/usr/local/autobench/var/tmp/build/linux/drivers/net/lib8390.c:310: first defined here
> ld: Warning: size of symbol `ei_start_xmit' changed from 598 in drivers/net/8390.o to 610 in drivers/net/8390p.o
> drivers/net/8390p.o: In function `ei_tx_timeout':
> /usr/local/autobench/autotest/tmp/build/linux/drivers/net/lib8390.c:263: multiple definition of `ei_tx_timeout'
> drivers/net/8390.o:/usr/local/autobench/var/tmp/build/linux/drivers/net/lib8390.c:263: first defined here
> drivers/net/8390p.o: In function `ei_set_multicast_list':
> /usr/local/autobench/autotest/tmp/build/linux/drivers/net/lib8390.c:999: multiple definition of `ei_set_multicast_list'
> drivers/net/8390.o:/usr/local/autobench/var/tmp/build/linux/drivers/net/lib8390.c:999: first defined here
> make[2]: *** [drivers/net/built-in.o] Error 1

Hi,
I just reported this on netdev and said that DaveM might want to drop a patch
that I had submitted.  Anyway, I'm looking into it.

Thanks.
