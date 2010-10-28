From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: ethtool: missing implementation of n_priv_flags
Date: Thu, 28 Oct 2010 13:34:34 -0700
Message-ID: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "jgarzik@redhat.com" <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7956 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156Ab0J1Uek convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 16:34:40 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was just looking at implementing the driver private flags to add a new feature to 
a driver.

It appears that nothing in the core ethtool.c ever accesses or prints n_priv_flags, 
even if a driver assigns it (which none in the kernel currently do)

Is this just an oversight?
