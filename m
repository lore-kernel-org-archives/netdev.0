From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] napi: use non-interruptible sleep in napi_disable
Date: Fri, 26 Oct 2007 04:23:41 -0700 (PDT)
Message-ID: <20071026.042341.177691569.davem@davemloft.net>
References: <20071025035920.C2D39DDECE@ozlabs.org>
	<47202548.6040100@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759373AbXJZLXy@vger.kernel.org>
In-Reply-To: <47202548.6040100@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Thu, 25 Oct 2007 01:10:32 -0400

> Benjamin Herrenschmidt wrote:
> > The current napi_disable() uses msleep_interruptible() but doesn't
> > (and can't) exit in case there's a signal, thus ending up doing a
> > hot spin without a cpu_relax. Use uninterruptible sleep instead.
> > 
> > Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
 ...
> ACK

Applied, thanks everyone.
