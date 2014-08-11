From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: Don't deschedule NAPI when
 carrier off
Date: Mon, 11 Aug 2014 13:17:37 +0100
Message-ID: <20140811121737.GC3249@zion.uk.xensource.com>
References: <1407758504-8150-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407758504-8150-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 11, 2014 at 01:01:44PM +0100, Zoltan Kiss wrote:
> In the patch called "xen-netback: Turn off the carrier if the guest is not able
> to receive" NAPI was descheduled when the carrier was set off. That's
> not what most of the drivers do, and we don't have any specific reason to do so
> as well, so revert that change.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org

Acked-by: Wei Liu <wei.liu2@citrix.com>
