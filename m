From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: 8139cp: Don't blindly enable interrupts in cp_start_xmit
Date: Tue, 16 Jan 2007 10:34:13 +1100
Message-ID: <20070115233413.GA11037@gondor.apana.org.au>
References: <45ABAE69.4070105@redhat.com> <20070115195635.GA14205@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Lalancette <clalance@redhat.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2153 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932082AbXAOXen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 18:34:43 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20070115195635.GA14205@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 15, 2007 at 08:56:35PM +0100, Francois Romieu wrote:
> 
> As I understand http://lkml.org/lkml/2006/12/12/239, something like the
> patch below should had been sent instead. Herbert, ack/nak ?

Sorry, what I said in that thread is in error.  Netpoll may
unfortunately call the transmit routine with IRQs off.  So
the drivers can't currently use spin_lock_irq and must save
the current flags instead.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
