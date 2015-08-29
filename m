From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ravb: propagate platform_get_irq() error upstream
Date: Fri, 28 Aug 2015 22:26:17 -0700 (PDT)
Message-ID: <20150828.222617.2059651130537411431.davem@davemloft.net>
References: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
	<1625516.DmSERANoIv@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	horms@verge.net.au
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1625516.DmSERANoIv@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 28 Aug 2015 16:55:10 +0300

> The driver overrides the error returned by platform_get_irq() with -ENODEV
> which e.g. precludes the deferred  probing from working. Propagate the real
> error code to the driver core instead.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
