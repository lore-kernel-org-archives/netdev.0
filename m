From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 17:53:16 +0800
Message-ID: <20071010095316.GA32095@gondor.apana.org.au>
References: <1191967006.5324.14.camel@localhost> <20071009.170435.43504422.davem@davemloft.net> <20071010003716.GB552@one.firstfloor.org> <20071009.175025.59469417.davem@davemloft.net> <20071010091644.GA9807@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	shemminger@linux-foundation.org, jeff@garzik.org,
	johnpol@2ka.mipt.ru, gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, kaber@trash.net
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1665 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755499AbXJJJyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:54:50 -0400
Content-Disposition: inline
In-Reply-To: <20071010091644.GA9807@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2007 at 11:16:44AM +0200, Andi Kleen wrote:
> > A 256 entry TX hw queue fills up trivially on 1GB and 10GB, but if you
> 
> With TSO really? 

Hardware queues are generally per-page rather than per-skb so
it'd fill up quicker than a software queue even with TSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
