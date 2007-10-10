From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 09:42:28 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903C0899A@orsmsx414.amr.corp.intel.com>
References: <20071010.034446.85819294.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC32903C0883E@orsmsx414.amr.corp.intel.com> <20071010160211.GA14239@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <hadi@cyberus.ca>,
	<shemminger@linux-foundation.org>, <jeff@garzik.org>,
	<johnpol@2ka.mipt.ru>, <herbert@gondor.apana.org.au>,
	<gaagaan@gmail.com>, <Robert.Olsson@data.slu.se>,
	<netdev@vger.kernel.org>, <rdreier@cisco.com>,
	<mcarlson@broadcom.com>, <jagana@us.ibm.com>,
	<general@lists.openfabrics.org>, <mchan@broadcom.com>,
	<tgraf@suug.ch>, <randy.dunlap@oracle.com>, <sri@us.ibm.com>,
	<kaber@trash.net>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59474 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbXJJQmb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 12:42:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071010160211.GA14239@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andi Kleen [mailto:andi@firstfloor.org] 
> Sent: Wednesday, October 10, 2007 9:02 AM
> To: Waskiewicz Jr, Peter P
> Cc: David Miller; andi@firstfloor.org; hadi@cyberus.ca; 
> shemminger@linux-foundation.org; jeff@garzik.org; 
> johnpol@2ka.mipt.ru; herbert@gondor.apana.org.au; 
> gaagaan@gmail.com; Robert.Olsson@data.slu.se; 
> netdev@vger.kernel.org; rdreier@cisco.com; 
> mcarlson@broadcom.com; jagana@us.ibm.com; 
> general@lists.openfabrics.org; mchan@broadcom.com; 
> tgraf@suug.ch; randy.dunlap@oracle.com; sri@us.ibm.com; 
> kaber@trash.net
> Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net 
> core use batching
> 
> > We've done similar testing with ixgbe to push maximum descriptor 
> > counts, and we lost performance very quickly in the same 
> range you're 
> > quoting on NIU.
> 
> Did you try it with WC writes to the ring or CLFLUSH?
> 
> -Andi

Hmm, I think it might be slightly different, but it still shows queue
depth vs. performance.  I was actually referring to how many descriptors
we can represent a packet with before it becomes a problem wrt
performance.  This morning I tried to actually push my ixgbe NIC hard
enough to come close to filling the ring with packets (384-byte
packets), and even on my 8-core Xeon I can't do it.  My system can't
generate enough I/O to fill the hardware queues before CPUs max out.

-PJ Waskiewicz
