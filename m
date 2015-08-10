From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bna: fix interrupts storm caused by erroneous
 packets
Date: Mon, 10 Aug 2015 10:58:23 -0700 (PDT)
Message-ID: <20150810.105823.1492211213957567690.davem@davemloft.net>
References: <1438894103-10597-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097AbbHJR6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 13:58:24 -0400
In-Reply-To: <1438894103-10597-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu,  6 Aug 2015 22:48:23 +0200

> The commit "e29aa33 bna: Enable Multi Buffer RX" moved packets counter
> increment from the beginning of the NAPI processing loop after the check
> for erroneous packets so they are never accounted. This counter is used
> to inform firmware about number of processed completions (packets).
> As these packets are never acked the firmware fires IRQs for them again
> and again.
> 
> Fixes: e29aa33 bna: Enable Multi Buffer RX
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
