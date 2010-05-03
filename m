From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] macvtap: add ioctl to modify vnet header size
Date: Mon, 3 May 2010 10:55:11 +0300
Message-ID: <20100503075511.GA8298@redhat.com>
References: <20100429135158.GA26303@redhat.com> <201004291640.57280.arnd@arndb.de> <20100502.233232.66719719.davem@davemloft.net> <20100502.233439.77341308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arnd@arndb.de, sri@us.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dlstevens@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932153Ab0ECH7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 03:59:09 -0400
Content-Disposition: inline
In-Reply-To: <20100502.233439.77341308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 02, 2010 at 11:34:39PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sun, 02 May 2010 23:32:32 -0700 (PDT)
> 
> > From: Arnd Bergmann <arnd@arndb.de>
> > Date: Thu, 29 Apr 2010 16:40:57 +0200
> > 
> >> On Thursday 29 April 2010, Michael S. Tsirkin wrote:
> >>> This adds TUNSETVNETHDRSZ/TUNGETVNETHDRSZ support
> >>> to macvtap.
> >> 
> >> Looks good, thanks Michael!
> >> 
> >>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >> 
> >> Acked-by: Arnd Bergmann <arnd@arndb.de>
> > 
> > Applied to net-next-2.6, thanks.
> 
> Nevermind, reverted:
> 
> drivers/net/macvtap.c: In function 'macvtap_ioctl':
> drivers/net/macvtap.c:679:7: error: 'TUNGETVNETHDRSZ' undeclared (first use in this function)
> drivers/net/macvtap.c:679:7: note: each undeclared identifier is reported only once for each function it appears in
> drivers/net/macvtap.c:685:7: error: 'TUNSETVNETHDRSZ' undeclared (first use in this function)
> 
> What tree is this supposed to build under?  Certinaly not net-2.6
> or net-next-2.6

The reason is it needs to be applied on top of the patch that adds the
same header to tun that you acked.  I put this in patch description:
> I plan to merge both patches through vhost tree together
> with mergeable buffer support. Comments?
In other words, this will be included in a pull request that I
intend to send out shortly.

-- 
MST
