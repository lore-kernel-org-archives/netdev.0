From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 10:46:00 +0800
Message-ID: <20071009024600.GA15215@gondor.apana.org.au>
References: <20071008.184126.124062865.davem@davemloft.net> <20071009020115.GA14635@gondor.apana.org.au> <20071009020318.GA14708@gondor.apana.org.au> <20071008.194343.52093065.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4942 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754550AbXJICqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 22:46:50 -0400
Content-Disposition: inline
In-Reply-To: <20071008.194343.52093065.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 08, 2007 at 07:43:43PM -0700, David Miller wrote:
> 
> Right, that's Jamal's recent patch.  It looked funny to me too.

Hang on Dave.  It was too early in the morning for me :)

I'd forgotten about the QDISC_RUNNING bit which did what the
queue lock did without actually holding the queue lock.

So there is no reordering with or without Jamal's patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
