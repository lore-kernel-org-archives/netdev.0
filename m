From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] xen-netback: Fix vif->disable handling
Date: Thu, 07 Aug 2014 16:04:24 -0700 (PDT)
Message-ID: <20140807.160424.419426873249476082.davem@davemloft.net>
References: <1407415118-16365-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407415118-16365-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Thu, 7 Aug 2014 13:38:38 +0100

> In the patch called "xen-netback: Turn off the carrier if the guest is not able
> to receive" new branches were introduced to this if statement, risking that a
> queue with non-zero id can reenable the disabled interface.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> ---
> v2: fix a code style error in this "if" as well

Applied.
