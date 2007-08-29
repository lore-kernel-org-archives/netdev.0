From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 0/9 Rev3] Implement batching skb API and support in IPoIB
Date: Wed, 29 Aug 2007 09:43:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC3290381E16F@orsmsx414.amr.corp.intel.com>
References: <20070828.215150.98552996.davem@davemloft.net><OF46DAD75A.5ADE5863-ON65257346.001C9AA3-65257346.001CB0F4@in.ibm.com> <20070828.221448.123919361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <gaagaan@gmail.com>, <general@lists.openfabrics.org>,
	<hadi@cyberus.ca>, <herbert@gondor.apana.org.au>,
	<jagana@us.ibm.com>, <jeff@garzik.org>, <johnpol@2ka.mipt.ru>,
	<kaber@trash.net>, <kumarkr@linux.ibm.com>,
	<mcarlson@broadcom.com>, <mchan@broadcom.com>,
	<netdev@vger.kernel.org>, <netdev-owner@vger.kernel.org>,
	<rdreier@cisco.com>, <rick.jones2@hp.com>,
	<Robert.Olsson@data.slu.se>, <shemminger@linux-foundation.org>,
	<sri@us.ibm.com>, <tgraf@suug.ch>, <xma@us.ibm.com>
To: "David Miller" <davem@davemloft.net>, <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23379 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbXH2QnO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 12:43:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070828.221448.123919361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Krishna Kumar2 <krkumar2@in.ibm.com>
> Date: Wed, 29 Aug 2007 10:43:23 +0530
> 
> > The reason was to run parallel copies, not for buffer limitations.
> 
> Oh, I see.
> 
> I'll note in passing that current lmbench-3 has some 
> parallelization features you could play with, you might want 
> to check it out.

I've also used iperf for parallel connections successfully, and that
will allow you to mess with the buffer sizes as well along with other
variables of the data streams for both TCP and UDP.

Cheers,
-PJ
