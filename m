From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: do not report success if
 backend_create_xenvif() fails
Date: Mon, 24 Nov 2014 16:14:57 -0500 (EST)
Message-ID: <20141124.161457.416165119227187597.davem@davemloft.net>
References: <20141124100053.GC30053@zion.uk.xensource.com>
	<1416826680-19145-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416826680-19145-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Mon, 24 Nov 2014 13:58:00 +0300

> If xenvif_alloc() or xenbus_scanf() fail in backend_create_xenvif(),
> xenbus is left in offline mode but netback_probe() reports success.
> 
> The patch implements propagation of error code for backend_create_xenvif().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
