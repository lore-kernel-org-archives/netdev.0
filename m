From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macsec: ensure rx_sa is set when validation is disabled
Date: Tue, 26 Jul 2016 14:28:13 -0700 (PDT)
Message-ID: <20160726.142813.1871912367017354571.davem@davemloft.net>
References: <1469528693-6578-1-git-send-email-bgalvani@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
	hannes@stressinduktion.org
To: bgalvani@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757950AbcGZV2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 17:28:14 -0400
In-Reply-To: <1469528693-6578-1-git-send-email-bgalvani@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Beniamino Galvani <bgalvani@redhat.com>
Date: Tue, 26 Jul 2016 12:24:53 +0200

> macsec_decrypt() is not called when validation is disabled and so
> macsec_skb_cb(skb)->rx_sa is not set; but it is used later in
> macsec_post_decrypt(), ensure that it's always initialized.
> 
> Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>

Applied and queued up for -stable.
