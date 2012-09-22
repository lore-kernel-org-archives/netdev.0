From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: drop PPPOX_ZOMBIEs in pppoe_release
Date: Sat, 22 Sep 2012 15:51:44 -0400 (EDT)
Message-ID: <20120922.155144.1725496101166891963.davem@davemloft.net>
References: <CANEcBPR8EvBTsJ0tG+kqvn578qXnqTMwdciS_WChe9sm5yKdaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stid.smth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEcBPR8EvBTsJ0tG+kqvn578qXnqTMwdciS_WChe9sm5yKdaw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xiaodong Xu <stid.smth@gmail.com>
Date: Sat, 22 Sep 2012 18:09:32 +0800

> From: Xiaodong Xu <stid.smth@gmail.com>
> 
> When PPPOE is running over a virtual ethernet interface (e.g., a
> bonding interface) and the user tries to delete the interface in case
> the PPPOE state is ZOMBIE, the kernel will loop forever while
> unregistering net_device for the reference count is not decreased to
> zero which should have been done with dev_put().
> 
> Signed-off-by: Xiaodong Xu <stid.smth@gmail.com>

Applied and queued up for -stable, thanks.
