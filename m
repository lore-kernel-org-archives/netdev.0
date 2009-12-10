From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Thu, 10 Dec 2009 10:55:33 -0800
Message-ID: <1260471333.1868.6.camel@Joe-Laptop.home>
References: <pvmfx7jbn2h.fsf@chavey.mtv.corp.google.com>
	 <20091210085719.4dae2bce@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chavey@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	therbert@google.com, eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1071 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754000AbZLJSz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 13:55:28 -0500
In-Reply-To: <20091210085719.4dae2bce@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-12-10 at 08:57 -0800, Stephen Hemminger wrote:
> You could use the hole in the structure:
>                 snd_wscale : 4, /* Window scaling received from sender  */
>                 rcv_wscale : 4; /* Window scaling to send to receiver   */
> +	u8	init_rcv_wnd;	/* TCP initial receive window in MSS */
> /*      SACKs data      */
>         u8      num_sacks;      /* Number of SACK blocks        

That hole got filled by tcp cookies.

