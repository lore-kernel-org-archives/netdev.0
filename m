From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 9 Oct 2007 10:16:46 +0800
Message-ID: <20071009021646.GB14917@gondor.apana.org.au>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com> <1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org> <20071008.184126.124062865.davem@davemloft.net> <20071009020115.GA14635@gondor.apana.org.au> <20071009020318.GA14708@gondor.apana.org.au> <20071009020442.GA14746@gondor.apana.org.au> <1191896149.4373.157.camel@localhost>
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
Received: from rhun.apana.org.au ([64.62.148.172]:4591 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750952AbXJICRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 22:17:21 -0400
Content-Disposition: inline
In-Reply-To: <1191896149.4373.157.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 08, 2007 at 10:15:49PM -0400, jamal wrote:
> On Tue, 2007-09-10 at 10:04 +0800, Herbert Xu wrote:
> 
> > Please revert
> > 
> > commit 41843197b17bdfb1f97af0a87c06d24c1620ba90
> > Author: Jamal Hadi Salim <hadi@cyberus.ca>
> > Date:   Tue Sep 25 19:27:13 2007 -0700
> > 
> >     [NET_SCHED]: explict hold dev tx lock
> > 
> > As this change introduces potential reordering and I don't think
> > we've discussed this aspect sufficiently.
> 
> How does it introduce reordering?

No it doesn't.  I'd forgotten about the QDISC_RUNNING bit :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
