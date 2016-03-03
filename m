From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6/l3mdev: Move host route on saved
 address if necessary
Date: Thu, 03 Mar 2016 17:11:52 -0500 (EST)
Message-ID: <20160303.171152.433623280324026428.davem@davemloft.net>
References: <1456595957-29477-1-git-send-email-dsa@cumulusnetworks.com>
	<20160301.172312.1539246311423803200.davem@davemloft.net>
	<56D64606.7040202@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182AbcCCWLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:11:54 -0500
In-Reply-To: <56D64606.7040202@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 1 Mar 2016 17:46:46 -0800

> Would you prefer the host route always get freed on a down and
> re-created on an up?

That would create yet another thing that can cause the re-up to fail
:-/
