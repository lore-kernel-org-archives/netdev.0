From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: make atmdev_ops const
Date: Wed, 09 Aug 2017 22:44:01 -0700 (PDT)
Message-ID: <20170809.224401.279024579244491378.davem@davemloft.net>
References: <1502270355-4231-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, 3chas3@gmail.com,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: bhumirks@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502270355-4231-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bhumika Goyal <bhumirks@gmail.com>
Date: Wed,  9 Aug 2017 14:49:15 +0530

> Make these structures const as they are either passed to the function
> atm_dev_register having the corresponding argument as const or stored in
> the ops field of a atm_dev structure, which is also const.
> Done using Coccinelle.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Applied.
