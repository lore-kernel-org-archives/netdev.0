From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: do not report success if xenvif_alloc()
 fails
Date: Mon, 24 Nov 2014 10:00:53 +0000
Message-ID: <20141124100053.GC30053@zion.uk.xensource.com>
References: <1416610588-19816-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ldv-project@linuxtesting.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416610588-19816-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 22, 2014 at 01:56:28AM +0300, Alexey Khoroshilov wrote:
> If xenvif_alloc() failes, netback_probe() reports success as well as
> "online" uevent is emitted. It does not make any sense, but it just

Sorry, I don't follow. KOBJ_ONLINE event is not emitted in the event of
xenvif_alloc fails, is it?

> misleads users.
> 
> The patch implements propagation of error code if xenvif creation fails.
> 

This patch not only implements propagation of error code when xenvif
creation fails, but also when xenbus_scanf fails. You can simply write
"This patch implements propagation of error code for
backend_create_xenvif".

The rest of this patch looks good to me. Can you rewrite commit message
and resubmit, thanks.

Wei.
