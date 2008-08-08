From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bnx2x: fix logical op
Date: Thu, 07 Aug 2008 20:33:33 -0700 (PDT)
Message-ID: <20080807.203333.140488055.davem@davemloft.net>
References: <20080807135314.8d87e1a2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, eilong@broadcom.com,
	akpm@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60391
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753378AbYHHDdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 23:33:32 -0400
In-Reply-To: <20080807135314.8d87e1a2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 7 Aug 2008 13:53:14 -0700

> Fix dubious logical operation that was found by sparse:
> linux-next-20080807/drivers/net/bnx2x_main.c:7205:27: warning: dubious: !x & y
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Looks obviously correct to me, applied, thanks Randy!
