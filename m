From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wireless: airo: remove unnecessary static in
 writerids()
Date: Wed, 19 Jul 2017 16:34:43 -0700 (PDT)
Message-ID: <20170719.163443.111801342022545425.davem@davemloft.net>
References: <20170718203711.GA30044@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: gustavo@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718203711.GA30044@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Tue, 18 Jul 2017 15:37:11 -0500

> Remove unnecessary static on local function pointer _writer_.
> Such pointer is initialized before being used, on every
> execution path throughout the function. The static has no
> benefit and, removing it reduces the object file size.
> 
> This issue was detected using Coccinelle and the following semantic patch:
 ...
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Applied.
