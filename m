From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Mon, 06 Aug 2007 13:50:47 -0700 (PDT)
Message-ID: <20070806.135047.55149298.davem@davemloft.net>
References: <20070805.232423.21363072.davem@davemloft.net>
	<1551EAE59135BE47B544934E30FC4FC002AABA1D@nt-irva-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761318AbXHFUus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 16:50:48 -0400
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC002AABA1D@nt-irva-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 6 Aug 2007 11:00:45 -0700

> David Miller wrote:
> 
> > 4) NETPOLL put hopefully into a working state.
> 
> It's no longer necessary to change the tx locking scheme
> in bnx2.c and tg3.c, right?  May be you forgot to revert
> the tx locking changes you did in V4?

Right, I'll fix that up, thanks for catching it.
