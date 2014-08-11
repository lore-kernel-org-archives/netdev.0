From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xen-netback: Don't deschedule NAPI when
 carrier off
Date: Mon, 11 Aug 2014 14:08:05 -0700 (PDT)
Message-ID: <20140811.140805.1937682654021661445.davem@davemloft.net>
References: <1407758504-8150-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407758504-8150-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 11 Aug 2014 13:01:44 +0100

> In the patch called "xen-netback: Turn off the carrier if the guest is not able
> to receive" NAPI was descheduled when the carrier was set off. That's
> not what most of the drivers do, and we don't have any specific reason to do so
> as well, so revert that change.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied, thanks.
