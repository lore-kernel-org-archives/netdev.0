From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Wed, 29 Apr 2015 15:21:26 -0400 (EDT)
Message-ID: <20150429.152126.847523297244536648.davem@davemloft.net>
References: <1430269188-31701-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430269188-31701-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Tue, 28 Apr 2015 17:59:48 -0700

> Commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated memory
> allocation in the packet send path:
> 
>     "hv_netvsc: Eliminate memory allocation in the packet send path
> 
>     The network protocol used to communicate with the host is the remote ndis (rndis)
>     protocol. We need to decorate each outgoing packet with a rndis header and
>     additional rndis state (rndis per-packet state). To manage this state, we
>     currently allocate memory in the transmit path. Eliminate this allocation by
>     requesting additional head room in the skb."
> 
> This commit introduced a bug since it did not account for the case if the skb
> was cloned. Fix this bug.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
