From: Michael Guntsche <michael.guntsche@it-loops.com>
Subject: Re: [PATCH][net-next] gianfar: Add backwards compatible Single Queue
 mode polling
Date: Mon, 10 Jun 2013 19:35:38 +0200
Message-ID: <CALG0vJtQkM65kr2-u5G578uzAFeCk5=bkKNU5BaBheXTHmc7+g@mail.gmail.com>
References: <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
	<1370884788-4862-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:59545 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab3FJRfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 13:35:40 -0400
Received: by mail-vc0-f179.google.com with SMTP id hz11so951671vcb.24
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 10:35:39 -0700 (PDT)
In-Reply-To: <1370884788-4862-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Claudiu,

On Mon, Jun 10, 2013 at 7:19 PM, Claudiu Manoil
<claudiu.manoil@freescale.com> wrote:
> Older Single Queue (SQ_SG_MODE) devices like TSEC (i.e. mpc83xx)
> don't feature the frame receive indication bits (RXF) in RSTAT.
> For these and for the rest of the SQ_SG_MODE devices, provide the
> appropiate polling routine that handles a single pair of Rx/Tx
> BD rings, removing the overhead incurred by the multiple queues/
> multiple interrupt group devices (veTSEC/ eTSEC2.0 devices).
> So this is primarily a fix for the TSEC devices.
>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c | 51 ++++++++++++++++++++++++++++++--
>  1 file changed, 49 insertions(+), 2 deletions(-)
>
<snip>
I can confirm that this fixes the problem for my TSEC based board.

/Mike
