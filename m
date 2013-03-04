From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] CAIF: fix sparse warning for caif_usb
Date: Mon, 04 Mar 2013 02:00:49 -0500 (EST)
Message-ID: <20130304.020049.833578984874387629.davem@davemloft.net>
References: <1362379920-26126-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sjur.brandeland@stericsson.com,
	linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362379920-26126-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Mon,  4 Mar 2013 08:52:00 +0200

> This fixes the following sparse warning:
> net/caif/caif_usb.c:84:16: warning: symbol 'cfusbl_create' was not
> declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
> ---
>  net/caif/caif_usb.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
> index 3ebc8cb..1c6ded9 100644
> --- a/net/caif/caif_usb.c
> +++ b/net/caif/caif_usb.c
> @@ -81,8 +81,8 @@ static void cfusbl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
>  		layr->up->ctrlcmd(layr->up, ctrl, layr->id);
>  }
>  
> -struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
> -					u8 braddr[ETH_ALEN])
> +static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
> +							u8 braddr[ETH_ALEN])

Nope, that indentation isn't correct, is should be:

static struct cflayer *cfusbl_create(int phyid, u8 ethaddr[ETH_ALEN],
				     u8 braddr[ETH_ALEN])

Read my email, I said that the first character on the second line
must line up with the first column after the openning parenthesis
of the first line.
