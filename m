From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] r8169: fix a race between PCI probe and dev_open
Date: Thu, 01 Feb 2007 13:40:35 +1100
Message-ID: <E1HCRsJ-0007sg-00@gondolin.me.apana.org.au>
References: <20070131213428.GA17534@electric-eye.fr.zoreil.com>
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, bwalle@suse.de
To: romieu@fr.zoreil.com (Francois Romieu)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4651 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933338AbXBACl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 21:41:29 -0500
In-Reply-To: <20070131213428.GA17534@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> wrote:
> 
> rtl8169_init_phy is only used on rtl8169_init_one so it's fine to never
> ask it to activate the timer: the racing dev->open will do it anyway.

Does rtl8169_init_phy need to occur after register_netdev? Normally
register_netdev should be the very last thing in a probe routine.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
