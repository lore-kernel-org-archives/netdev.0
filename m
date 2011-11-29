From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Tue, 29 Nov 2011 18:23:33 -0500 (EST)
Message-ID: <20111129.182333.365445684859306013.davem@davemloft.net>
References: <1322585087.25018.115.camel@icts-sp-039>
	<alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeroen@zijndomein.nl, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485Ab1K2XXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:23:47 -0500
In-Reply-To: <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 30 Nov 2011 01:06:46 +0200 (EET)

> 	May be the solution is to convert inet_addr_lst
> from hlist to normal list, so that we can append new
> addresses at tail and __ip_dev_find to find the first
> device where IP was added.

Sure, but do we really want to guarentee this behavior forever?
