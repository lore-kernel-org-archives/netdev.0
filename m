From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IFF_RUNNING without carrier after reboot
Date: Mon, 15 Dec 2008 18:28:00 +1100
Message-ID: <E1LC7s0-0007qm-T3@gondolin.me.apana.org.au>
References: <20081214.222951.190945313.davem@davemloft.net>
Cc: marcel@holtmann.org, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55810 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751743AbYLOH2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 02:28:09 -0500
In-Reply-To: <20081214.222951.190945313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> The RUNNING state has no connection to link presence.
> 
> It just means that the device has been brought up by a
> user configuration command like the ifconfig you ran.
> 
> It really means nothing else.

Well RUNNING did use to indicate carrier state.  In fact I didn't
even know that it had changed until this email :)

This is the changeset which did it:

commit b00055aacdb172c05067612278ba27265fcd05ce
Author: Stefan Rompf <stefan@loplof.de>
Date:   Mon Mar 20 17:09:11 2006 -0800

    [NET] core: add RFC2863 operstate

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
