From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 10:16:20 +0800
Message-ID: <20071009021620.GA14917@gondor.apana.org.au>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com> <1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org> <20071008.184126.124062865.davem@davemloft.net> <1191896071.4373.156.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	peter.p.waskiewicz.jr@intel.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4582 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750844AbXJICRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 22:17:12 -0400
Content-Disposition: inline
In-Reply-To: <1191896071.4373.156.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 08, 2007 at 10:14:30PM -0400, jamal wrote:
>
> You forgot QDISC_RUNNING Dave;-> the above cant happen. 
> Essentially at any one point in time, we are guaranteed that we can have
> multiple cpus enqueueing but only can be dequeueing (the one that
> managed to grab QDISC_RUNNING) i.e multiple producers to the qdisc queue
> but only one consumer. Only the dequeuer has access to the txlock.

Good point.  You had me worried for a sec :)

Dave, Jamal's patch is fine as it is and doesn't actually create
any packet reordering.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
