From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] vxlan: Add support for zero UDP6 checksums
Date: Tue, 13 May 2014 18:48:02 -0400 (EDT)
Message-ID: <20140513.184802.1863631448443267898.davem@davemloft.net>
References: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391AbaEMWsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 18:48:03 -0400
In-Reply-To: <alpine.DEB.2.02.1405120952470.12635@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 12 May 2014 09:59:25 -0700 (PDT)

> Added module parameters to specify sending of TX checksums and
> allow receiving RX checksums. Also added a module parameter and
> support for using IPv4 checksums on TX (default is off so zero
> checksums are sent).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Tom, definitely do not do this using module parameters.

Extend the vxlan configuration to suppose this switch using netlink.

Thanks.
