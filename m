From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: bond_slave_info_query() fix
Date: Fri, 01 May 2009 15:16:38 -0700 (PDT)
Message-ID: <20090501.151638.262689731.davem@davemloft.net>
References: <49F04FD7.7080508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55693
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026AbZEAWQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 18:16:44 -0400
In-Reply-To: <49F04FD7.7080508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 23 Apr 2009 13:24:07 +0200

> bond_slave_info_query() should keep a read lock while accessing slave info,
> or risk accessing stale data and corruption.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
