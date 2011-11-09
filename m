From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ll_temac: FIX : Wait for indirect wait to end
Date: Wed, 09 Nov 2011 15:40:06 -0500 (EST)
Message-ID: <20111109.154006.436356200830517997.davem@davemloft.net>
References: <1320745197-11053-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, eric.dumazet@gmail.com,
	jeffrey.t.kirsher@intel.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ricardo.ribalda@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320745197-11053-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Date: Tue,  8 Nov 2011 10:39:57 +0100

> While tracing down a connectivity problem on the temac I connected a
> probe to the Cross bar irq, and it was triggered when doing
> ifdown->ifup.
> 
> This is fixed once waiting for the indirect write to end. Since it is
> not on the hot path there is no performance loss.
> 
> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>

Also applied, thanks.
