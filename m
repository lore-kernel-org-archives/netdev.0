From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] xen-netfront: do not cast grant table reference to
 signed short
Date: Mon, 31 Oct 2016 16:06:23 -0400 (EDT)
Message-ID: <20161031.160623.714189344925104774.davem@davemloft.net>
References: <1477892309-7150-1-git-send-email-dongli.zhang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, boris.ostrovsky@oracle.com,
        david.vrabel@citrix.com, jgross@suse.com
To: dongli.zhang@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477892309-7150-1-git-send-email-dongli.zhang@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dongli Zhang <dongli.zhang@oracle.com>
Date: Mon, 31 Oct 2016 13:38:29 +0800

> While grant reference is of type uint32_t, xen-netfront erroneously casts
> it to signed short in BUG_ON().
> 
> This would lead to the xen domU panic during boot-up or migration when it
> is attached with lots of paravirtual devices.
> 
> Signed-off-by: Dongli Zhang <dongli.zhang@oracle.com>

Since this is consistent with how the macros in linux/err.h handle "is
this an error" checks, this change looks good to me.

Applied, thanks.
