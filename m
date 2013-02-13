From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [PATCH v4 4/9] rdma/cm: Update port reservation to support AF_IB
Date: Wed, 13 Feb 2013 18:19:51 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237368B9A432@ORSMSX101.amr.corp.intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
 <1358891797-14625-5-git-send-email-sean.hefty@intel.com>
 <511B7474.3040201@mellanox.com>
 <1828884A29C6694DAF28B7E6B8A8237368B9A40F@ORSMSX101.amr.corp.intel.com>
 <20130213181048.GC1601@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29361 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760089Ab3BMSTx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 13:19:53 -0500
In-Reply-To: <20130213181048.GC1601@obsidianresearch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sean, I've lost track of all this over time, but just to check in,
> with this new interface, would it be possible to obsolete ib_ucm? That
> seems desirable to me, as it is so flawed..

I'd love to obsolete ib_ucm.  This interface should make it possible, though some additional implementation would be needed (e.g. for automatic path migration).

I have an immediate need to connect using native IB addresses.  So without this, I'll be forced to use ib_ucm or roll a new user space CM.
