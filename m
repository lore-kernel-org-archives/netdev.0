From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] I/OAT repost
Date: Tue, 23 May 2006 17:22:10 -0700 (PDT)
Message-ID: <20060523.172210.78710967.davem@davemloft.net>
References: <20060524001653.19403.31396.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:7657
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932508AbWEXAWK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 20:22:10 -0400
To: christopher.leech@intel.com
In-Reply-To: <20060524001653.19403.31396.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Leech <christopher.leech@intel.com>
Subject: [PATCH 0/9] I/OAT repost
Date: Tue, 23 May 2006 17:16:53 -0700

> This is a repost of the I/OAT patches, the only changes from last time
> are refreshing the patches and removing an unused macro that was causing
> the vger spam filters to drop patch 2/9.
> 
> This patch series is the a full release of the Intel(R) I/O
> Acceleration Technology (I/OAT) for Linux.  It includes an in kernel API
> for offloading memory copies to hardware, a driver for the I/OAT DMA memcpy
> engine, and changes to the TCP stack to offload copies of received
> networking data to application space.

I'm going to apply this into a net-2.6.18 GIT tree, do some build
and sanity checking, then ask Andrew to pull it into -mm for testing.

Thanks guys.
