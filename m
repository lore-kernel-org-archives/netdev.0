From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] atm: Remove fix me in solos-pci
Date: Tue, 22 Jul 2014 07:43:32 -0400
Message-ID: <20140722074332.52b8c66b@thirdoffive.cmf.nrl.navy.mil>
References: <1406002040-7334-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:56819 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753974AbaGVLnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 07:43:53 -0400
In-Reply-To: <1406002040-7334-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guy Ellis of Transverse says that Nathan Williams,
nathan@traverse.com.au, will address this issue when he returns
from vacation.  So let's just wait for the 'official' fix.

On Tue, 22 Jul 2014 00:07:20 -0400
Nicholas Krause <xerofoify@gmail.com> wrote:

> This removes a fix me as the default statement for solos_bh is correct
> and needs no fixing.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/atm/solos-pci.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
> index 943cf0d..58a0a8f 100644
> --- a/drivers/atm/solos-pci.c
> +++ b/drivers/atm/solos-pci.c
> @@ -851,7 +851,7 @@ static void solos_bh(unsigned long card_arg)
>  				break;
>  
>  			case PKT_COMMAND:
> -			default: /* FIXME: Not really, surely? */
> +			default:
>  				if (process_command(card, port, skb))
>  					break;
>  				spin_lock(&card->cli_queue_lock);
