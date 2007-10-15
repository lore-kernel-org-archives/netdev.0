From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Fix performance regression on 5705.
Date: Mon, 15 Oct 2007 02:14:44 -0700 (PDT)
Message-ID: <20071015.021444.99184027.davem@davemloft.net>
References: <1192217947.6987.2.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, andy@greyhouse.net
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58711
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753678AbXJOJOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:14:40 -0400
In-Reply-To: <1192217947.6987.2.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 12 Oct 2007 12:39:07 -0700

> [TG3]: Fix performance regression on 5705.
> 
> A performance regression was introduced by the following commit:
> 
>     commit ee6a99b539a50b4e9398938a0a6d37f8bf911550
>     Author: Michael Chan <mchan@broadcom.com>
>     Date:   Wed Jul 18 21:49:10 2007 -0700
> 
>     [TG3]: Fix msi issue with kexec/kdump.
> 
> In making that change, the PCI latency timer and cache line size
> registers were not restored after chip reset.  On the 5705, the
> latency timer gets reset to 0 during chip reset and this causes
> very poor performance.
> 
> Update version to 3.84.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.

This might be what was causing the 5714 performance problems I was
seeing on one of my systems, I'll go check that out when I get a
chance.

Thanks again!
