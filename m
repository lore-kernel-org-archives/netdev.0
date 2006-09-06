From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/7] 8139cp: ring_info removal for the receive path
Date: Wed, 06 Sep 2006 10:47:00 -0400
Message-ID: <44FEDF64.4000105@pobox.com>
References: <20060831204717.GA13650@electric-eye.fr.zoreil.com> <20060831204954.GC14181@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:5849 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750910AbWIFOrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 10:47:04 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060831204954.GC14181@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> The ring_info.len field is not used at all. cp_private.rx_skb is
> turned into an array of sk_buff *.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Need to remove the now-dead struct ring_info.

Otherwise, patchset looks OK.

When fixed, I'll pull into #upstream, just let me know...

	Jeff



