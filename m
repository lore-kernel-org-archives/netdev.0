From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inetpeer: Add support for VRFs
Date: Tue, 25 Aug 2015 15:52:38 -0700 (PDT)
Message-ID: <20150825.155238.480716811707267406.davem@davemloft.net>
References: <55DA7AFE.5040301@cumulusnetworks.com>
	<20150825.134759.1592811364914291771.davem@davemloft.net>
	<55DCEF20.5080908@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbbHYWwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:52:39 -0400
In-Reply-To: <55DCEF20.5080908@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 25 Aug 2015 15:41:36 -0700

> Meaning rename struct inetpeer_addr to struct inetpeer_key and
> addr_compare to entry_compare or key_compare?

I'm not talking about inetpeer specifically, but generally speaking
everywhere you're going to have to handle this including inetpeer.

So something like "inet4_daddr_key" which is a __be32 and the ifindex.
