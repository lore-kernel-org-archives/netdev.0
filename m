From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: remove unnecessary static in qlcnic_dump_fw()
Date: Wed, 19 Jul 2017 16:35:04 -0700 (PDT)
Message-ID: <20170719.163504.1972586469015417785.davem@davemloft.net>
References: <20170718204529.GA11448@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: gustavo@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718204529.GA11448@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Tue, 18 Jul 2017 15:45:29 -0500

> Remove unnecessary static on local variable fw_dump_ops.
> Such variable is initialized before being used, on every
> execution path throughout the function. The static has no
> benefit and, removing it reduces the object file size.
> 
> This issue was detected using Coccinelle and the following semantic patch:
 ...
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Applied.
