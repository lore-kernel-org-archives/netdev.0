From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] liquidio: lio_main: remove unnecessary static in
 setup_io_queues()
Date: Wed, 19 Jul 2017 16:34:30 -0700 (PDT)
Message-ID: <20170719.163430.2283130742325293687.davem@davemloft.net>
References: <20170718205348.GA25613@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: gustavo@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170718205348.GA25613@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Tue, 18 Jul 2017 15:53:48 -0500

> Remove unnecessary static on local variables cpu_id_modulus and cpu_id.
> Such variables are initialized before being used, on every execution
> path throughout the function. The static has no benefit and, removing
> it reduces the object file size.
> 
> This issue was detected using Coccinelle and the following semantic patch:
...
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Applied.
