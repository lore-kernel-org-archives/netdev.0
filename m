From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/9] atm: propagate signal changes via notifier
Date: Thu, 08 Jul 2010 21:47:45 -0700 (PDT)
Message-ID: <20100708.214745.48520104.davem@davemloft.net>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
	<1278578095-25324-2-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
To: karl@hiramoto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33226
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750811Ab0GIErc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 00:47:32 -0400
In-Reply-To: <1278578095-25324-2-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Hiramoto <karl@hiramoto.org>
Date: Thu,  8 Jul 2010 10:34:47 +0200

> +
> +/*
> + * atm_dev_signal_change
> + *
> + * Propagate lower layer signal change in atm_dev->signal to netdevice.
> + * The event will be sent via a notifier call chain.
> + */

I said to format comments:

/* Like
 * this.
 */

not:

/*
 * Like
 * this.
 */

Honestly, I don't know how I can be more clear about this :-)
