From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis190: fix cable detect via link status poll
Date: Tue, 02 Mar 2010 03:45:11 -0800 (PST)
Message-ID: <20100302.034511.161195805.davem@davemloft.net>
References: <20100301204009.GA15782@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46528
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750833Ab0CBLox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 06:44:53 -0500
In-Reply-To: <20100301204009.GA15782@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 1 Mar 2010 15:40:09 -0500

> Some sis190 devices don't report LinkChange, so do polling for
> link status.
> 
> Fixes http://bugzilla.kernel.org/show_bug.cgi?id=11926
> 
> Signed-off-by: Herton Ronaldo Krzesinski <herton@mandriva.com.br>

Applied, thanks for giving life to this patch Jeff.

I'll stick this into 2.6.34 and if we want we can backport it
to -stable after it cooks there for a while.

Thanks again.
