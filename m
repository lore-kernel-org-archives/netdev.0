From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix a race between PCI probe and dev_open
Date: Thu, 1 Feb 2007 09:28:11 +0100
Message-ID: <20070201082811.GB1011@electric-eye.fr.zoreil.com>
References: <20070131213428.GA17534@electric-eye.fr.zoreil.com> <E1HCRsJ-0007sg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com, bwalle@suse.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56643 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422652AbXBAI3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 03:29:16 -0500
Content-Disposition: inline
In-Reply-To: <E1HCRsJ-0007sg-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> :
[...]
> Normally register_netdev should be the very last thing in a probe routine.

Yes. I did not feel safe changing it before 2.6.20.

-- 
Ueimor
