From: David Miller <davem@davemloft.net>
Subject: Re: [v3] net: ethernet: cavium: octeon: octeon_mgmt: Handle return
 NULL error from devm_ioremap
Date: Mon, 19 Dec 2016 11:04:20 -0500 (EST)
Message-ID: <20161219.110420.1570801461162159172.davem@davemloft.net>
References: <1481742210-5609-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.chen@nxp.com, fw@strlen.de, david.daney@cavium.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481742210-5609-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Thu, 15 Dec 2016 00:33:30 +0530

> Here, If devm_ioremap will fail. It will return NULL.
> Kernel can run into a NULL-pointer dereference.
> This error check will avoid NULL pointer dereference.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Since ioremap() is in fact designed to possibly fail, we do
need to always check it's return value.  So this change is
correct and I have applied it to the 'net' tree.

Thanks.
