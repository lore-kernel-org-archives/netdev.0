From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Fri, 14 Sep 2007 10:45:23 -0700
Message-ID: <000001c7f6f7$074584e0$9c98070a@amr.corp.intel.com>
References: <adahclymos8.fsf@cisco.com><000401c7f632$c993e8e0$65cc180a@amr.corp.intel.com> <adatzpyl1mm.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <general@lists.openfabrics.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "'Roland Dreier'" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39160 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753259AbXINRp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 13:45:58 -0400
In-Reply-To: <adatzpyl1mm.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>OK -- just to make sure I'm understanding what you're saying: have you
>confirmed that your proposed patches actually fix the issue?

Not directly.  I cannot easily test kernel patches on our larger, production
clusters.  We've seen the issue with specific applications on 512 and 1024
cores, but I've only been able to test the patch on a 48-core cluster.  I have
verified that it successfully increases the timeout to where it *should* work,
but cannot absolutely confirm that it will fix the problem.  I'm unlikely to
know that until the production clusters move to an OFED release (1.3?)
containing this patch.

- Sean
