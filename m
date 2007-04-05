From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: Multiqueue network device support, replayed.
Date: Thu, 5 Apr 2007 14:33:19 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329029ADBC2@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Cramer, Jeb J" <jeb.j.cramer@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9686 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767334AbXDEVdV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 17:33:21 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,
	Please consider pulling from my git tree:

	git-pull git://lost.foo-projects.org/~ppwaskie/git/net-2.6.22
multiqueue

This is a branch named 'multiqueue' of a recent pull from your tree with
an updated implementation of the multiqueue implementation we've been
working on.  Included in this is:

1) A simplified API where all drivers will allocate a queue struct for
each queue on the NIC.
2) A transparent stack change for both non-mq and mq devices to use the
same codepath.
3) Remove the per-queue locking model, and just use the per-queue
netif_{start|stop|wake}_subqueue() functions for multiqueue management.
4) Updated multiqueue documentation in Documentation/networking
describing the implementation and base driver requirements to implement
multiqueue support.

Cheers,

PJ Waskiewicz
Intel Corp.
peter.p.waskiewicz.jr@intel.com
