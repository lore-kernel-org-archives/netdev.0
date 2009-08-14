From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: Fix MTU calculation for bound GRE tunnels
Date: Fri, 14 Aug 2009 16:34:35 -0700 (PDT)
Message-ID: <20090814.163435.90268783.davem@davemloft.net>
References: <20090814183758.GA21197@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55256
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751640AbZHNXeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:34:24 -0400
In-Reply-To: <20090814183758.GA21197@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Goff <thomas.goff@boeing.com>
Date: Fri, 14 Aug 2009 11:37:58 -0700

> The GRE header length should be subtracted when the tunnel MTU is
> calculated.  This just corrects for the associativity change
> introduced by commit 42aa916265d740d66ac1f17290366e9494c884c2.
> 
> Signed-off-by: Tom Goff <thomas.goff@boeing.com>

Thanks for finding and fixing this bug, applied.
