From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: RE: [net-next 2.6 PATCH] net/pcmcia: convert to use
Date: Sun, 21 Feb 2010 11:32:53 +0100
Message-ID: <20100221103245.GA2584@psychotron.redhat.com>
References: <5083689.85171266728689181.ken_kawasaki@spring.nifty.jp>
 <9571361.89671266729917620.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040Ab0BUKc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2010 05:32:59 -0500
Content-Disposition: inline
In-Reply-To: <9571361.89671266729917620.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 21, 2010 at 06:25:17AM CET, ken_kawasaki@spring.nifty.jp wrote:
>Hi,
>
>"ifndef final_version" is unnecessary in smc91c92_cs.c,
>isn't it?
>
>-#ifndef final_version		/* Verify multicast address. */
>-		if ((mc_addr->dmi_addr[0] & 1) == 0)
>-		    continue;
>-#endif

Right, looks like it is. Feel free to send the patch to remove this.

Jirka
>
>
>Ken
>
