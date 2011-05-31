From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: ks8842 Fix crash on received packet when
 in PIO mode.
Date: Tue, 31 May 2011 15:15:40 -0700 (PDT)
Message-ID: <20110531.151540.20835046.davem@davemloft.net>
References: <20110529214652.GA4707@dens-work>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: info@mocean-labs.com, netdev@vger.kernel.org
To: dennis.aberilla@mimomax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702Ab1EaWPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 18:15:51 -0400
In-Reply-To: <20110529214652.GA4707@dens-work>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dennis Aberilla <dennis.aberilla@mimomax.com>
Date: Mon, 30 May 2011 09:46:54 +1200

> This patch fixes a driver crash during packet reception due to not enough
> bytes allocated in the skb. Since the loop reads out 4 bytes at a time, we
> need to allow for up to 3 bytes of slack space.
> 
> Signed-off-by: Dennis Aberilla <denzzzhome@yahoo.com>

Applied, thanks.

> |Dennis
> =======================================================================
> This email, including any attachments, is only for the intended
> addressee.  It is subject to copyright, is confidential and may be
> the subject of legal or other privilege, none of which is waived or
> lost by reason of this transmission.
> If the receiver is not the intended addressee, please accept our
> apologies, notify us by return, delete all copies and perform no
> other act on the email.
> Unfortunately, we cannot warrant that the email has not been
> altered or corrupted during transmission.
> =======================================================================

Please turn this off for future patch submissions or I will
completely ignore them.  It is entirely inappropriate for emails
destined for a public mailing list.

Thanks.
