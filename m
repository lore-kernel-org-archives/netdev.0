From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iovec: move memcpy_from/toiovecend to lib/iovec.c
Date: Thu, 19 Jun 2014 21:06:37 -0700 (PDT)
Message-ID: <20140619.210637.1702701955085552032.davem@davemloft.net>
References: <1403201568-22828-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, rdunlap@infradead.org,
	sfr@canb.auug.org.au, hjk@hansjkoch.de, gregkh@linuxfoundation.org,
	stephen@networkplumber.org, sean.hefty@intel.com,
	fx.lebail@yahoo.com, jasowang@redhat.com,
	hannes@stressinduktion.org, wuzhy@linux.vnet.ibm.com,
	nab@linux-iscsi.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403201568-22828-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 19 Jun 2014 21:22:56 +0300

> ERROR: "memcpy_fromiovecend" [drivers/vhost/vhost_scsi.ko] undefined!
> 
> commit 9f977ef7b671f6169eca78bf40f230fe84b7c7e5
>     vhost-scsi: Include prot_bytes into expected data transfer length
> in target-pending makes drivers/vhost/scsi.c call memcpy_fromiovecend().
> This function is not available when CONFIG_NET is not enabled.
> 
> socket.h already includes uio.h, so no callers need updating.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> David, could you please ack merging this through
> target-pending to avoid dependency issues?

Yep, this looks fine:

Signed-off-by: David S. Miller <davem@davemloft.net>
