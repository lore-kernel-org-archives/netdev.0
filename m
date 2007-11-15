From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before calling hard_start_xmit
Date: Thu, 15 Nov 2007 12:57:42 -0800
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903FC5AF9@orsmsx414.amr.corp.intel.com>
References: <20071114060412.9556.84833.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: "Krishna Kumar" <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10240 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754408AbXKOU7V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 15:59:21 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071114060412.9556.84833.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You could optimize this by getting HARD_TX_LOCK after the 
> check. I assume that netif_stop_subqueue (from another CPU) 
> would always be called by the driver xmit, and that is not 
> possible since we hold the __LINK_STATE_QDISC_RUNNING bit. 
> Does that sound correct?

Sorry for not responding sooner; Dave hit it on the head though with his
response.  I agree with your changes, and I'll incorporate them in the
lockless stack patches I've been working on (in the software queuing
mode).  Now if I could just find some time to finish them up and get
them out for review...

Thanks,

-PJ Waskiewicz
