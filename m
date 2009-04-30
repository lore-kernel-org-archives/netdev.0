From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH] FlexRay: Allocate numbers for FlexRay communication
Date: Thu, 30 Apr 2009 19:28:01 +0200
Message-ID: <49F9DFA1.30100@hartkopp.net>
References: <20090430163825.GX13310@m58s01.vlinux.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Arndt <flexray4linux@scriptkiller.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:14557 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932809AbZD3R2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 13:28:09 -0400
In-Reply-To: <20090430163825.GX13310@m58s01.vlinux.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Arndt wrote:

> This patch adds a protocol family, Ethernet protocol ID,
> ARP protocol identifier and a line discipline for FlexRay
> communication using Linux.
> 
> I do not know why ETH_P_CAN has been chosen to be 0x000C

perhaps because of 'C'AN ?

> 
> Further code including the FlexRay core, raw sockets and
> examples will soon be posted on a yet-to-be-created project site.

Usually there's a project and some kind of community that worked, discussed
and tested the stuff for some time to be mature for mainline.

- What is the technical background?
- Is there any documentation?
- Do you need realtime?
- What hardware is supported?

> +++ b/include/linux/tty.h
> @@ -23,7 +23,7 @@
>   */

>  /* line disciplines */
>  #define N_TTY		0
> @@ -46,6 +46,7 @@
>  #define N_GIGASET_M101	16	/* Siemens Gigaset M101 serial DECT adapter */
>  #define N_SLCAN		17	/* Serial / USB serial CAN Adaptors */
>  #define N_PPS		18	/* Pulse per Second */
> +#define N_SLFLEXRAY	19	/* Serial / USB serial FlexRay adapters */

???

I bet there's no Flexray hardware on the market that can be attached on a
serial line like there are for low-cost CAN adaptors, right?

So why are you claiming a line discipline here?

Regards,
Oliver
