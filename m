From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ethtool: add dynamic flag to ETHTOOL_{GS}RXFH
 commands
Date: Thu, 04 Feb 2016 19:30:55 -0500 (EST)
Message-ID: <20160204.193055.2172651314284452037.davem@davemloft.net>
References: <1454455328-706-2-git-send-email-jacob.e.keller@intel.com>
	<20160204.175326.492457129636004051.davem@davemloft.net>
	<1454627396.3086.14.camel@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, shannon.nelson@intel.com, aduyck@mirantis.com,
	thomas.petazzoni@free-electrons.com, mcarlson@broadcom.com,
	yuvalmin@broadcom.com, amirv@mellanox.com,
	mitch.a.williams@intel.com, _govind@gmx.com,
	Lendacky@vger.kernel.org, emil.s.tantilov@intel.com,
	bhutchings@solarflare.com, mirq-linux@rere.qmqm.pl,
	hariprasad@chelsio.com, kalesh.purayil@emulex.com,
	netdev@vger.kernel.org, mchan@broadcom.com,
	carolyn.wyborny@intel.com, sgoutham@cavium.com,
	Thomas.Lendacky@amd.com, achiad@mellanox.com
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731AbcBEAbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 19:31:06 -0500
In-Reply-To: <1454627396.3086.14.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Date: Thu, 4 Feb 2016 23:09:56 +0000

> So you're suggesting instead, to error when the second operation
> (change number of queues) would fail the current settings?

Yes.

This is absolutely required.
