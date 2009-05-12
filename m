From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] rio: warn_unused_result warnings fix
Date: Tue, 12 May 2009 15:11:12 -0700
Message-ID: <20090512151112.7e2a3e74.akpm@linux-foundation.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
	<1242117363-14949-2-git-send-email-leoli@freescale.com>
	<1242117363-14949-3-git-send-email-leoli@freescale.com>
	<1242117363-14949-4-git-send-email-leoli@freescale.com>
	<1242117363-14949-5-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, davem@davemloft.net,
	mporter@kernel.crashing.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	leoli@freescale.com
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39820 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756577AbZELWPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 18:15:44 -0400
In-Reply-To: <1242117363-14949-5-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 16:36:02 +0800
Li Yang <leoli@freescale.com> wrote:

> +	if (rswitch) {
> +		if (rswitch->route_table)

this `if' is unneeded.

> +			kfree(rswitch->route_table);
> +		kfree(rswitch);
> +	}
