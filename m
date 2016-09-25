From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/5] ISDN-CAPI: Delete unnecessary braces
Date: Sun, 25 Sep 2016 14:18:47 +0300
Message-ID: <52dd5000-2bda-a1b6-aa97-1868e1193d35@cogentembedded.com>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
 <06e7637c-f682-bfa2-82b6-47d071bd58c4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <06e7637c-f682-bfa2-82b6-47d071bd58c4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/25/2016 2:15 PM, SF Markus Elfring wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sun, 25 Sep 2016 12:50:21 +0200
>
> Do not use curly brackets at eight source code places
> where a single statement should be sufficient.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/isdn/capi/capidrv.c | 30 +++++++++++-------------------
>  1 file changed, 11 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
> index 83f756d..7f58644 100644
> --- a/drivers/isdn/capi/capidrv.c
> +++ b/drivers/isdn/capi/capidrv.c
[...]
> @@ -976,13 +974,12 @@ static void handle_controller(_cmsg *cmsg)
>  		if (debugmode)
>  			printk(KERN_DEBUG "capidrv-%d: listenconf Info=0x%4x (%s) cipmask=0x%x\n",
>  			       card->contrnr, cmsg->Info, capi_info2str(cmsg->Info), card->cipmask);
> -		if (cmsg->Info) {
> +		if (cmsg->Info)
>  			listen_change_state(card, EV_LISTEN_CONF_ERROR);
> -		} else if (card->cipmask == 0) {
> +		else if (card->cipmask == 0)
>  			listen_change_state(card, EV_LISTEN_CONF_EMPTY);
> -		} else {
> +		     else

    Indented too much.

[...]

MBR, Sergei
