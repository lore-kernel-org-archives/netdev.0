From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: do not report success if
 backend_create_xenvif() fails
Date: Mon, 24 Nov 2014 11:03:08 +0000
Message-ID: <20141124110308.GA322@zion.uk.xensource.com>
References: <20141124100053.GC30053@zion.uk.xensource.com>
 <1416826680-19145-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ldv-project@linuxtesting.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416826680-19145-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 01:58:00PM +0300, Alexey Khoroshilov wrote:
> If xenvif_alloc() or xenbus_scanf() fail in backend_create_xenvif(),
> xenbus is left in offline mode but netback_probe() reports success.
> 
> The patch implements propagation of error code for backend_create_xenvif().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks!
