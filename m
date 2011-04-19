From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 17/34] hdlcdrv: Drop __TIME__ usage
Date: Tue, 19 Apr 2011 12:17:49 +0200
Message-ID: <4DAD614D.1060704@bfs.de>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz> <1302015561-21047-18-git-send-email-mmarek@suse.cz>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org,
	Thomas Sailer <t.sailer@alumni.ethz.ch>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-18-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 05.04.2011 16:59, schrieb Michal Marek:
> The kernel already prints its build timestamp during boot, no need to
> repeat it in random drivers and produce different object files each
> time.
> 
> Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
> Cc: linux-hams@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Marek <mmarek@suse.cz>
> ---
>  drivers/net/hamradio/hdlcdrv.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
> index 5b37579..a4a3516 100644
> --- a/drivers/net/hamradio/hdlcdrv.c
> +++ b/drivers/net/hamradio/hdlcdrv.c
> @@ -749,7 +749,7 @@ EXPORT_SYMBOL(hdlcdrv_unregister);
>  static int __init hdlcdrv_init_driver(void)
>  {
>  	printk(KERN_INFO "hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA\n");
> -	printk(KERN_INFO "hdlcdrv: version 0.8 compiled " __TIME__ " " __DATE__ "\n");
> +	printk(KERN_INFO "hdlcdrv: version 0.8\n");
>  	return 0;
>  }
>  

Its a bit late but i am not a big fan of hard coded version id's.
Does GIT provide something like that ? If not
IMHO the line
 printk(KERN_INFO "hdlcdrv: version 0.8\n");
can be removed.

re,
 wh
