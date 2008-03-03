From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Removing unneeded statement from tcp_ipv4.c
Date: Mon, 03 Mar 2008 10:51:05 -0800 (PST)
Message-ID: <20080303.105105.189914871.davem@davemloft.net>
References: <47CBFBDA.7000801@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hannemann@nets.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38145
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbYCCSvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 13:51:21 -0500
In-Reply-To: <47CBFBDA.7000801@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Date: Mon, 03 Mar 2008 14:23:38 +0100

> -       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval) {
> +       if (tmp_opt.saw_tstamp && !tmp_opt.rcv_tsval)
>                 /* Some OSes (unknown ones, but I see them on web server, which
>                  * contains information interesting only for windows'
>                  * users) do not send their stamp in SYN. It is easy case.
>                  * We simply do not advertise TS support.
>                  */
>                 tmp_opt.saw_tstamp = 0;
> -               tmp_opt.tstamp_ok  = 0;
> -       }
> +

Please don't format it like this.

When there is a multi-line comment, you should still enclose
the basic block in braces.  It's unreadable otherwise.
