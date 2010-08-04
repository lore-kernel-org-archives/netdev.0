From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH net-next 09/14] tg3: Improve small packet performance
Date: Thu, 5 Aug 2010 09:08:25 +1000
Message-ID: <20100804230825.GQ29316@kryten>
References: <1280784368-4226-9-git-send-email-mcarlson@broadcom.com>
 <20100804222741.GA18708@kryten>
 <1280962049.7554.25.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Carlson <mcarlson@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58112 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759363Ab0HDXNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 19:13:07 -0400
Content-Disposition: inline
In-Reply-To: <1280962049.7554.25.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
Hi,

> We generally only get an estimate of the available tx ring size when we
> call tg3_tx_avail(), so memory barriers are not generally needed.  We
> put a compiler barrier there to make sure that the compiler will fetch
> the tx_prod and tx_cons from memory to give us a better estimate.
> 
> In specific cases detailed in the patch description, we do need memory
> barriers when we call netif_tx_stop_queue() and then check for the tx
> ring.  We decided to put memory barriers exactly where they're needed
> instead of inside tg3_tx_avail() which is an overkill.

Thanks Matt and Michael. I was pretty sure you were thinking about
ordering issues but wanted to double check.

Anton
