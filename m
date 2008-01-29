From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Mon, 28 Jan 2008 21:14:41 -0800 (PST)
Message-ID: <20080128.211441.37469687.davem@davemloft.net>
References: <Pine.LNX.4.58.0801261439020.7864@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joonwpark81@gmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752432AbYA2FOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 00:14:24 -0500
In-Reply-To: <Pine.LNX.4.58.0801261439020.7864@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 26 Jan 2008 14:41:32 +0200 (EET)

> 
> 	fib_info can be shared by many route prefixes but we don't
> want duplicate alternative routes for a prefix+tos+priority. Last
> change was not correct to check fib_treeref because it accounts usage
> from other prefixes. Additionally, avoid replacement without error
> if new route is same, as Joonwoo Park suggests.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thank you.
