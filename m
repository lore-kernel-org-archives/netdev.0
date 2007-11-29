From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH (resubmit)] Fix inet_diag.ko register vs rcv race
Date: Fri, 30 Nov 2007 00:10:15 +1100
Message-ID: <20071129131015.GB8487@gondor.apana.org.au>
References: <474EB825.8000601@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3550 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758451AbXK2NKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 08:10:21 -0500
Content-Disposition: inline
In-Reply-To: <474EB825.8000601@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 04:01:25PM +0300, Pavel Emelyanov wrote:
> 
> Besides, as Herbert pointed out, asynchronous dumps should hold 
> this mutex as well, and thus, we provide the mutex as cb_mutex one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks for the quick response! Patch applied to net-2.6.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
