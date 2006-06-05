From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Mon, 05 Jun 2006 14:29:45 -0700
Message-ID: <1149542985.13155.11.camel@rh4>
References: <1149536852.13155.7.camel@rh4>
 <20060605155834.031d37a2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:45329 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750772AbWFEXJS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:09:18 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060605155834.031d37a2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-05 at 15:58 -0700, Stephen Hemminger wrote:

> 
> Since you are going more lockless, you probably need memory barriers.

No, we're not going more lockless. We're simply replacing the private
tx_lock with dev->xmit_lock by dropping the LLTX feature flag. The
amount of locking is exactly the same as before.


