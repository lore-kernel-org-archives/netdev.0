From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Mon, 26 Sep 2011 17:00:49 -0400 (EDT)
Message-ID: <20110926.170049.1943390151354224651.davem@davemloft.net>
References: <1317055319.2773.41.camel@bwh-desktop>
	<20110926094719.0cb6c296@nehalam.linuxnetplumber.net>
	<184D23435BECB444AB6B9D4630C8EC83028F8A71@XMB-RCD-303.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: benve@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294Ab1IZVBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 17:01:03 -0400
In-Reply-To: <184D23435BECB444AB6B9D4630C8EC83028F8A71@XMB-RCD-303.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Christian Benvenuti (benve)" <benve@cisco.com>
Date: Mon, 26 Sep 2011 15:54:53 -0500

> Does it mean that a Netlink interface becomes official (and backward
> compatibility should not be broken) only once iproute2 starts
> supporting it?

It needs to be analyzed on a case-by-case basis.  Sometimes we can quickly
fix a poorly designed netlink interface is no major tool takes on use of
the feature.
