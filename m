From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ksz884x: fix mtu for VLAN
Date: Thu, 12 Jan 2012 20:06:49 -0800 (PST)
Message-ID: <20120112.200649.82222668012696767.davem@davemloft.net>
References: <20120111231243.GA14836@dkehn-Latitude-D830>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rdkehn@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab2AMEGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 23:06:51 -0500
In-Reply-To: <20120111231243.GA14836@dkehn-Latitude-D830>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Kehn <rdkehn@yahoo.com>
Date: Wed, 11 Jan 2012 17:12:43 -0600

> The Ethernet header does not account for the addition of a VLAN header.
> Full size Ethernet frames containing VLAN header are not processed
> because the frame is larger than the resulting hw mtu.
> 
> Signed-off-by: Doug Kehn <rdkehn@yahoo.com>

Applied.
