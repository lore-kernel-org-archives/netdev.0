From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: Fix vif->disable handling
Date: Wed, 06 Aug 2014 14:08:11 -0700 (PDT)
Message-ID: <20140806.140811.1012784433206389073.davem@davemloft.net>
References: <1407353598-14185-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1407353598-14185-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 6 Aug 2014 20:33:18 +0100

> In the patch called "xen-netback: Turn off the carrier if the guest is not able
> to receive" new branches were introduced to this if statement, risking that a
> queue with non-zero id can reenable the disabled interface.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Can you please resubmit this with curly braces added to the first if()'s
basic block?

Thanks.
