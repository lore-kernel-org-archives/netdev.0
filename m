From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bridge: mdb: add support for extended
 attributes
Date: Thu, 18 Feb 2016 15:37:40 -0500 (EST)
Message-ID: <20160218.153740.101157132273397459.davem@davemloft.net>
References: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946394AbcBRUhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:37:43 -0500
In-Reply-To: <1455623214-2951-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Tue, 16 Feb 2016 12:46:52 +0100

> Note that the reason we can't simply add an attribute after
> MDBA_MDB_ENTRY_INFO is that current users (e.g. iproute2) walk over
> the attribute list directly without checking for the attribute type.

Honestly that sounds like a bug in iproute2 to me...
