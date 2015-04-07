From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,3/3] hv_netvsc: Fix the packet free when it is
 in skb headroom
Date: Tue, 07 Apr 2015 18:45:53 -0400 (EDT)
Message-ID: <20150407.184553.121069210906314065.davem@davemloft.net>
References: <1428358974-7958-1-git-send-email-haiyangz@microsoft.com>
	<1428358974-7958-3-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428358974-7958-3-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon,  6 Apr 2015 15:22:54 -0700

> In the two places changed, we now use netvsc_xmit_completion() which properly
> frees hv_netvsc_packet in or not in skb headroom.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
