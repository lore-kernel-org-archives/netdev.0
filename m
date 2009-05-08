From: David Miller <davem@davemloft.net>
Subject: Re: via velocity trivial patch
Date: Fri, 08 May 2009 12:41:07 -0700 (PDT)
Message-ID: <20090508.124107.210148762.davem@davemloft.net>
References: <4A01FBF6.1090001@podgorny.cz>
	<20090507.150213.192379856.davem@davemloft.net>
	<4A04184E.5040507@podgorny.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: radek@podgorny.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754813AbZEHTlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 15:41:11 -0400
In-Reply-To: <4A04184E.5040507@podgorny.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radek Podgorny <radek@podgorny.cz>
Date: Fri, 08 May 2009 13:32:30 +0200

> @@ -2226,8 +2226,8 @@
>  	spin_lock(&vptr->lock);
>  	isr_status = mac_read_isr(vptr->mac_regs);
>  
> - -	/* Not us ? */
> - -	if (isr_status == 0) {
> +	/* Not us or garbage ? */
> +	if (isr_status == 0 || isr_status == 0xffffffff) {

Your patch is also completely mangled and would not apply
anyways.
