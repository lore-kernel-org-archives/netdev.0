From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [BUILD_FAILURE] linux-next: 20081125 - 8390 network driver
 build fails
Date: Tue, 25 Nov 2008 19:57:56 +0000
Message-ID: <20081125195756.12317499@lxorguk.ukuu.org.uk>
References: <20081125213738.881b425e.sfr@canb.auug.org.au>
	<20081125182542.GA4914@linux.vnet.ibm.com>
	<492C464D.4080704@oracle.com>
	<20081125185154.2845e8f1@lxorguk.ukuu.org.uk>
	<492C5334.2090801@oracle.com>
	<20081125193853.076c7b58@lxorguk.ukuu.org.uk>
	<492C562E.9090302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	p_gortmaker@yahoo.com, netdev@vger.kernel.org, mel@csn.ul.ie
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <492C562E.9090302@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> drivers/net/8390p.o: In function `ei_get_stats':
> (.text+0x1050): multiple definition of `ei_get_stats'
> drivers/net/8390.o:(.text+0xe20): first defined here
> drivers/net/8390p.o: In function `ei_start_xmit':
> (.text+0x1100): multiple definition of `ei_start_xmit'
> drivers/net/8390.o:(.text+0xef0): first defined here
> drivers/net/8390p.o: In function `ei_tx_timeout':
> (.text+0xec0): multiple definition of `ei_tx_timeout'
> drivers/net/8390.o:(.text+0xce0): first defined here
> drivers/net/8390p.o: In function `ei_set_multicast_list':
> (.text+0x1000): multiple definition of `ei_set_multicast_list'
> drivers/net/8390.o:(.text+0xea0): first defined here
> make[2]: *** [drivers/net/built-in.o] Error 1
> 
> and none of these functions is static in lib8390.c.

They seem to be just fine in the base tree, so somebody has merged
something stoopid.


 */

static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)  
{
   


Alan
