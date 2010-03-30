From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 10/12] l2tp: Add L2TP ethernet pseudowire support
Date: Tue, 30 Mar 2010 09:30:55 -0700
Message-ID: <20100330093055.49336856@nehalam>
References: <20100330161725.9628.69994.stgit@bert.katalix.com>
	<20100330161819.9628.10853.stgit@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33048 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754433Ab0C3R0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 13:26:43 -0400
In-Reply-To: <20100330161819.9628.10853.stgit@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 17:18:19 +0100
James Chapman <jchapman@katalix.com> wrote:

> +
> +	/* Derive a MAC address for the new interface. We use the L2TP
> +	 * session's session-id to guarantee a system-wide unique
> +	 * address. This MAC is only visible within the L2TP session.
> +	 */
> +	dev->dev_addr[0] = 0x02; /* IEEE 802 local */
> +	dev->dev_addr[1] = 'L';
> +	memcpy(&dev->dev_addr[2], &sid, 4);

Why not random ether address?


-- 
