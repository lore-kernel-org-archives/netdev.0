From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8021q/vlan: process NETDEV_GOING_DOWN
Date: Tue, 29 May 2012 20:40:40 -0400 (EDT)
Message-ID: <20120529.204040.644013889059321702.davem@davemloft.net>
References: <1338330635-27259-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338330635-27259-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Wed, 30 May 2012 00:30:35 +0200

> In the current flow, when you take down a physical device that has
> VLANs configured on it, the NETDEV_GOING_DOWN notification will be
> sent too late, i.e., no data can be sent to the wire anymore.

Why do you need to send data?  Any queued up data should be purged not
sent.
