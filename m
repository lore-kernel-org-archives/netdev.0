From: Erik Mouw <erik@harddisk-recovery.com>
Subject: Re: [PATCH 11/21] nbd: limit blk_queue
Date: Wed, 6 Sep 2006 17:17:17 +0200
Message-ID: <20060906151716.GG16721@harddisk-recovery.com>
References: <20060906131630.793619000@chello.nl>> <20060906133954.845224000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dtp.xs4all.nl ([80.126.206.180]:64439 "HELO abra2.bitwizard.nl")
	by vger.kernel.org with SMTP id S1751401AbWIFPRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:17:19 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Disposition: inline
In-Reply-To: <20060906133954.845224000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 06, 2006 at 03:16:41PM +0200, Peter Zijlstra wrote:
> -		disk->queue = blk_init_queue(do_nbd_request, &nbd_lock);
> +		disk->queue = blk_init_queue_node_elv(do_nbd_request,
> +				&nbd_lock, -1, "noop");

So what happens if the noop scheduler isn't compiled into the kernel?


Erik

-- 
+-- Erik Mouw -- www.harddisk-recovery.com -- +31 70 370 12 90 --
| Lab address: Delftechpark 26, 2628 XH, Delft, The Netherlands
