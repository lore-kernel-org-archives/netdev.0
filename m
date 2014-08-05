From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net]tg3: Modify tg3_tso_bug() to handle multiple TX
 rings
Date: Tue, 05 Aug 2014 16:49:40 -0700 (PDT)
Message-ID: <20140805.164940.1613258811508714514.davem@davemloft.net>
References: <1407279722-1485-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60657 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbaHEXtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:49:41 -0400
In-Reply-To: <1407279722-1485-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Tue, 5 Aug 2014 16:02:02 -0700

> tg3_tso_bug() was originally designed to handle only HW TX ring 0, Commit
> d3f6f3a1d818410c17445bce4f4caab52eb102f1 ("tg3: Prevent page allocation failure
> during TSO workaround") changed the driver logic to use tg3_tso_bug() for all
> HW TX rings that are enabled. This patch fixes the regression by modifying
> tg3_tso_bug() to handle multiple HW TX rings.
> 
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable, thanks.
