From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 21:57:47 +1000
Message-ID: <20060816115747.GA29440@gondor.apana.org.au>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au> <20060816114003.GY14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:65036 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751115AbWHPL6W
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 07:58:22 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060816114003.GY14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 01:40:03PM +0200, Thomas Graf wrote:
> 
> It was added to help quagga identify which route modifications
> are self caused. It's not possible to use rtm_protocol for this
> purpose as other applications can delete routes added by quagga.

Actually it's not that bad.  I just checked the quagga source and
the stuff it needs was already provided anyway, even before that
change.

In fact, the really bad bits in the changeset have already been
reverted by Alexey back in February :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
