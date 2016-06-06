From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] hv_netvsc: cleanup after untangling
 the pointer mess
Date: Sun, 05 Jun 2016 23:17:50 -0400 (EDT)
Message-ID: <20160605.231750.966943160183728574.davem@davemloft.net>
References: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@linuxdriverproject.org,
	linux-kernel@vger.kernel.org, kys@microsoft.com,
	haiyangz@microsoft.com
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464969062-22132-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Fri,  3 Jun 2016 17:50:57 +0200

> Changes since v1:
> - resend when net-next is open [David Miller]
> - rebased to current net-next.
> 
> After we made traveling through our internal structures explicit it became
> obvious that some functions take arguments they don't need just to do
> redundant pointer travel and get to what they really need while their
> callers already have the required information.
> 
> This is just a cleanup series with no functional changes intended. It
> doesn't pretend to be complete, additional cleanup of other functions may
> follow.

Series applied, thanks.
