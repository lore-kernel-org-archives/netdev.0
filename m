From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ip_tunnel: GSO: Add check for nested encap.
Date: Tue, 10 Jun 2014 22:21:20 -0700 (PDT)
Message-ID: <20140610.222120.1648194413371340927.davem@davemloft.net>
References: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaFKFVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 01:21:23 -0400
In-Reply-To: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sun, 25 May 2014 04:39:32 -0700

> +	if (skb_is_gso(skb)) {
> +		if (unlikely(skb->encapsulation)) {
> +			/* Current networking GSO stack can handle
> +			 * only one level of encapsulation. */
> +			err = -ENOSYS;
> +			goto error;
> +		}

This is not the correct way to format a comment in the kernel networking
code, the proper way is:

	/* Like
	 * this.
	 */

Also, you need to provide a cover posting for a patch series explaining
at a high level what this patch series is accomplishing.  Also you need
to explicitly indicate what tree this set of changes is targetting.

Given the amount of changes you've contributed in the past, I am at a
loss as to why I have to explain all of this to someone with your level
of experience.
