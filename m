From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix: use wq_has_sleeper in unix_dgram_recvmsg
Date: Tue, 01 Dec 2015 14:48:03 -0500 (EST)
Message-ID: <20151201.144803.593589376680817466.davem@davemloft.net>
References: <878u5klgb8.fsf@doppelsaurus.mobileactivedefense.com>
	<874mg8lg4c.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874mg8lg4c.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Thu, 26 Nov 2015 19:23:15 +0000

> The current unix_dgram_recvmsg does a wake up for every received
> datagram. This seems wasteful as only SOCK_DGRAM client sockets in an
> n:1 association with a server socket will ever wait because of the
> associated condition. The patch below changes the function such that the
> wake up only happens if wq_has_sleeper indicates that someone actually
> wants to be notified. Testing with SOCK_SEQPACKET and SOCK_DGRAM socket
> seems to confirm that this is an improvment.
> 
> Signed-Off-By: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Applied, thanks.
