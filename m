From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [ofa-general] [PATCH v3] iw_cxgb3: Support "iwarp-only" interfaces to avoid 4-tuple conflicts.
Date: Thu, 27 Sep 2007 13:14:59 -0700
Message-ID: <000001c80143$15019140$82c8180a@amr.corp.intel.com>
References: <20070923203649.8324.64524.stgit@dell3.ogc.int> <46FBF8AF.9040700@ichips.intel.com> <46FC03B8.1030106@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <rdreier@cisco.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <general@lists.openfabrics.org>
To: "'Steve Wise'" <swise@opengridcomputing.com>,
	"Sean Hefty" <mshefty@ichips.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22300 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbXI0UPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2007 16:15:03 -0400
In-Reply-To: <46FC03B8.1030106@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>It is ok to block while holding a mutex, yes?

It's okay, I just didn't try to trace through the code to see if it ever tries
to acquire the same mutex in the thread that needs to signal the event.

- Sean
