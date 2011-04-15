From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: ignore looped-back NA while dad is running
Date: Fri, 15 Apr 2011 15:44:57 -0700 (PDT)
Message-ID: <20110415.154457.28809247.davem@davemloft.net>
References: <20110414070925.GA78446@0x90.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sahne@0x90.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110414070925.GA78446@0x90.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Walter <sahne@0x90.at>
Date: Thu, 14 Apr 2011 09:09:25 +0200

> [ipv6] Ignore looped-back NAs while in Duplicate Address Detection
> 
> If we send an unsolicited NA shortly after bringing up an
> IPv6 address, the duplicate address detection algorithm
> fails and the ip stays in tentative mode forever. 
> This is due a missing check if the NA is looped-back to us.
> 
> Signed-off-by: Daniel Walter <dwalter@barracuda.com>

Applied to net-next-2.6
