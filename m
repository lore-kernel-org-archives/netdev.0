From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: fix build warnings
Date: Mon, 04 Jul 2016 17:19:45 -0700 (PDT)
Message-ID: <20160704.171945.1411429111917733524.davem@davemloft.net>
References: <1467611618-4046-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, sfr@canb.auug.org.au
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968AbcGEATq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 20:19:46 -0400
In-Reply-To: <1467611618-4046-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon,  4 Jul 2016 13:53:38 +0800

> Stephen Rothwell reports a build warnings(powerpc ppc64_defconfig)
> 
> drivers/net/tun.c: In function 'tun_do_read.part.5':
> /home/sfr/next/next/drivers/net/tun.c:1491:6: warning: 'err' may be
> used uninitialized in this function [-Wmaybe-uninitialized]
>    int err;
> 
> This is because tun_ring_recv() may return an uninitialized err, fix this.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
