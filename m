From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: fix kfree on error path in new_steering_entry()
Date: Sun, 03 Apr 2011 22:04:10 -0700 (PDT)
Message-ID: <20110403.220410.123991133.davem@davemloft.net>
References: <1301865983-6584-1-git-send-email-mk@lab.zgora.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, rolandd@cisco.com, alekseys@voltaire.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mk@lab.zgora.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301865983-6584-1-git-send-email-mk@lab.zgora.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <mk@lab.zgora.pl>
Date: Sun,  3 Apr 2011 23:26:23 +0200

> On error path kfree() should get pointer to memory allocated by
> kmalloc() not the address of variable holding it (which is on stack).
> 
> Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>

Applied, thanks.
