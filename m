From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH] pcmci: remove odd bracket
Date: Sat, 9 Jan 2010 13:22:06 +0100
Message-ID: <20100109122206.GA7199@comet.dominikbrodowski.net>
References: <1262819146-21361-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:37508 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754013Ab0AIMiQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2010 07:38:16 -0500
Content-Disposition: inline
In-Reply-To: <1262819146-21361-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 02:05:46AM +0300, Alexander Beregalov wrote:
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>  drivers/net/pcmcia/nmclan_cs.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/pcmcia/nmclan_cs.c b/drivers/net/pcmcia/nmclan_cs.c
> index 8a5ae3b..12e3233 100644
> --- a/drivers/net/pcmcia/nmclan_cs.c
> +++ b/drivers/net/pcmcia/nmclan_cs.c
> @@ -1402,7 +1402,6 @@ static void BuildLAF(int *ladrf, int *adr)
>    for (i = 0; i < 8; i++)
>      printk(KERN_CONT " %02X", ladrf[i]);
>    printk(KERN_CONT "\n");
> -  }
>  #endif
>  } /* BuildLAF */

Thanks, merged your patch to the pcmcia git tree (but renamed it to:

	pcmcia: remove odd bracket in nmclan_cs.c

).

Best,
	Dominik
