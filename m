From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Convert to non-LLTX
Date: Mon, 5 Jun 2006 17:31:59 -0700
Message-ID: <20060605173159.33d81d59@localhost.localdomain>
References: <1149536852.13155.7.camel@rh4>
	<20060605155834.031d37a2@localhost.localdomain>
	<1149542985.13155.11.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:206 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750949AbWFFAcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 20:32:12 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1149542985.13155.11.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Jun 2006 14:29:45 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> On Mon, 2006-06-05 at 15:58 -0700, Stephen Hemminger wrote:
> 
> > 
> > Since you are going more lockless, you probably need memory barriers.
> 
> No, we're not going more lockless. We're simply replacing the private
> tx_lock with dev->xmit_lock by dropping the LLTX feature flag. The
> amount of locking is exactly the same as before.

Those spin lock's were also acting as barriers.
Are you sure code is safe in the face of cpu reordering.

-- 
If one would give me six lines written by the hand of the most honest
man, I would find something in them to have him hanged. -- Cardinal Richlieu
