From: Wan ZongShun <mcuos.com@gmail.com>
Subject: Re: [PATCH] net: Fix checks on unsigned in w90p910_ether_probe()
Date: Fri, 30 Oct 2009 14:18:36 +0800
Message-ID: <e68bb3470910292318j7a4d3e9fpcc9fe714a0561ef7@mail.gmail.com>
References: <4ADDFE0C.3020400@gmail.com>
	 <20091029.230624.125832796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>, roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:58234 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298AbZJ3GSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 02:18:31 -0400
Received: by pzk26 with SMTP id 26so1739150pzk.4
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 23:18:36 -0700 (PDT)
In-Reply-To: <20091029.230624.125832796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear sirs,

Okay, it is right, thanks all for your help.
I will re-fix it later.

2009/10/30, David Miller <davem@davemloft.net>:
> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Tue, 20 Oct 2009 20:14:36 +0200
>
> > ether->txirq and ->rxirq are unsigned
> >
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>
> platform_get_irq() returns a signed int so the intention
> is more likely that catching negative value returns
> was intended.
>
> Probably the correct fix is to mark txirq and rxirq as
> plain 'int'.
>


-- 
Wan z.s
