From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] Packet sniffer core framework
Date: Mon, 23 Feb 2015 16:37:17 -0500 (EST)
Message-ID: <20150223.163717.356301805782993412.davem@davemloft.net>
References: <cover.1424698609.git.stathis.voukelatos@linn.co.uk>
	<3f43e4376bec64ded755e202c11d2f07886194af.1424698609.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: stathis.voukelatos@linn.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3f43e4376bec64ded755e202c11d2f07886194af.1424698609.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Date: Mon, 23 Feb 2015 14:26:21 +0000

> +	spin_lock_irqsave(&priv->lock, flags);
> +	/* Stop the hardware */
> +	sch->stop(sch);
> +	/* Set the new command pattern */
> +	ret = sch->set_pattern(sch, skb->data, skb->len / 2);
> +	/* Restart the hardware */
> +	sch->start(sch);
> +	spin_unlock_irqrestore(&priv->lock, flags);

These comments are excessive.

When someone calls ops->stop() what are they supposed to think the
thing does?  Open a can of tuna?  Mow the lawn?  Wash the dishes?  No,
it stops the thing.  Everyone understands that and you don't have to
explicitly say it.

Saying "stop the hardware" does not add anything to the source code
that is not already implicitly there.  They just take up space and
keep more useful information from being displayed at once on the
screen.  Please remove all of these things.

Thanks.
