From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] cpmac: fix warning length cast
Date: Mon, 13 Dec 2010 10:16:16 -0800 (PST)
Message-ID: <20101213.101616.115951173.davem@davemloft.net>
References: <20101213171725.2ed299cf.yuasa@linux-mips.org>
	<20101213171845.39a2151f.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ejka@imfi.kspu.ru
To: yuasa@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55135
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751913Ab0LMSPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 13:15:48 -0500
In-Reply-To: <20101213171845.39a2151f.yuasa@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yoichi Yuasa <yuasa@linux-mips.org>
Date: Mon, 13 Dec 2010 17:18:45 +0900

> drivers/net/cpmac.c: In function 'cpmac_start_xmit':
> drivers/net/cpmac.c:569: warning: comparison of distinct pointer types
> lacks a cast
> 
> Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>

Again, you cannot change the types of the members of the
descriptor, as it has a fixed implementation and is read
by the hardware.
