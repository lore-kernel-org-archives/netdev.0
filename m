From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] sky2: Use seq_putc() in sky2_debug_show()
Date: Mon, 8 May 2017 19:08:40 +0200
Message-ID: <8594c152-68a4-c0c7-b4c6-49c753b0c748@gmx.de>
References: <1f36d45e-3ca9-bfb8-0634-901c42390e2c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:55091 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755168AbdEHRJO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 13:09:14 -0400
In-Reply-To: <1f36d45e-3ca9-bfb8-0634-901c42390e2c@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 08.05.2017 18:42, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 8 May 2017 18:38:17 +0200
> 
> A single character (line break) should be put into a sequence.

Why?

> Thus use the corresponding function "seq_putc".
> 
> This issue was detected by using the Coccinelle software.

Which issue do you mean? I dont see any issue you fix here.

> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/marvell/sky2.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 1145cde2274a..73575101cd72 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -4562,7 +4562,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
>  			seq_printf(seq, "[%d] %#x %d %#x\n",
>  				   idx, le->opcode, le->length, le->status);
>  		}
> -		seq_puts(seq, "\n");
> +		seq_putc(seq, '\n');
>  	}
>  
>  	seq_printf(seq, "Tx ring pending=%u...%u report=%d done=%d\n",
> 

Regards,
Lino
