From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NULL pointer dereference at
	2.6.32-rc8:net/ipv4/ip_fragment.c:566
Date: Tue, 1 Dec 2009 12:37:59 +0800
Message-ID: <20091201043759.GA22655@gondor.apana.org.au>
References: <523e55a00911250152n773f2cbeu9251180c44f0b9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, david@blue-labs.org,
	netdev@vger.kernel.org
To: David Ford <firefighterblu3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45964 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753058AbZLAEh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 23:37:58 -0500
Content-Disposition: inline
In-Reply-To: <523e55a00911250152n773f2cbeu9251180c44f0b9a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ford <firefighterblu3@gmail.com> wrote:
>
> hmm.  that shows a patch of code which is just prior to ip_defrag(), i.e.:
> 
>    565 out_fail:
>    566         IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);

Looks like a namespace problem.

Please open a bug report on bugzilla.kernel.org to ensure that
this is tracked.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
