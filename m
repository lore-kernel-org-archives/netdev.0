From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use kzalloc rather than kmalloc followed by
 memset with 0
Date: Mon, 21 Nov 2011 15:07:10 -0500 (EST)
Message-ID: <20111121.150710.927474462388773194.davem@davemloft.net>
References: <1321569820.1624.263.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321569820.1624.263.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Meyer <thomas@m3y3r.de>
Date: Thu, 17 Nov 2011 23:43:40 +0100

> This considers some simple cases that are common and easy to validate
> Note in particular that there are no ...s in the rule, so all of the
> matched code has to be contiguous
> 
> The semantic patch that makes this change is available
> in scripts/coccinelle/api/alloc/kzalloc-simple.cocci.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

Applied, with subject prefix fixed to be "ksz884x: "
