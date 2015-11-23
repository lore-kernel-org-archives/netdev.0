From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by
 index
Date: Sun, 22 Nov 2015 23:35:46 -0500 (EST)
Message-ID: <20151122.233546.578035475304956705.davem@davemloft.net>
References: <5651FBB8.6030008@cumulusnetworks.com>
	<20151122.131715.1858345389016284808.davem@davemloft.net>
	<56528FBC.6040205@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099AbbKWEfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 23:35:48 -0500
In-Reply-To: <56528FBC.6040205@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 22 Nov 2015 21:02:04 -0700

> I am confused by that response given that sk_bound_dev_if is one of
> the key principals for the VRF implementation. Applications wanting to
> communicate over interfaces in a VRF have to set sk_bound_dev_if.

Yes, they have to set it explicitly.

You are setting it for them in response to the connection
creation, and that's what I object to.
