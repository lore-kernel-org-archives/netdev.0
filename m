From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : dst_ifdown() cleanup
Date: Tue, 11 Dec 2007 02:00:55 -0800 (PST)
Message-ID: <20071211.020055.230547864.davem@davemloft.net>
References: <475E0B1A.9030406@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50195
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751187AbXLKKA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:00:56 -0500
In-Reply-To: <475E0B1A.9030406@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 11 Dec 2007 04:59:22 +0100

> This cleanup shrinks size of net/core/dst.o on i386 from 1299 to 1289 bytes.
> (This is because dev_hold()/dev_put() are doing atomic_inc()/atomic_dec() and 
> force compiler to re-evaluate memory contents.)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, thanks Eric.
