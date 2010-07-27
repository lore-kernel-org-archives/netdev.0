From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next 4/4] wireless: Convert wiphy_debug macro to
 function
Date: Tue, 27 Jul 2010 14:05:56 -0400
Message-ID: <20100727180556.GE31694@tuxdriver.com>
References: <cover.1280177971.git.joe@perches.com>
 <8e7aa541ec8fb92e1166920a4eb704aa5f851b71.1280177971.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37758 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296Ab0G0SPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 14:15:22 -0400
Content-Disposition: inline
In-Reply-To: <8e7aa541ec8fb92e1166920a4eb704aa5f851b71.1280177971.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 26, 2010 at 02:40:00PM -0700, Joe Perches wrote:
> Save a few bytes of text
> 
> (allyesconfig)
> $ size drivers/net/wireless/built-in.o*
>    text	   data	    bss	    dec	    hex	filename
> 3924568	 100548	 871056	4896172	 4ab5ac	drivers/net/wireless/built-in.o.new
> 3926520	 100548	 871464	4898532	 4abee4	drivers/net/wireless/built-in.o.old
> 
> $ size net/wireless/core.o*
>    text	   data	    bss	    dec	    hex	filename
>   12843	    216	   3768	  16827	   41bb	net/wireless/core.o.new
>   12328	    216	   3656	  16200	   3f48	net/wireless/core.o
> 
> Signed-off-by: Joe Perches <joe@perches.com>

> --- a/net/wireless/core.c
> +++ b/net/wireless/core.c
> @@ -907,3 +907,56 @@ static void __exit cfg80211_exit(void)
>  	destroy_workqueue(cfg80211_wq);
>  }
>  module_exit(cfg80211_exit);
> +
> +#ifdef __KERNEL__

Do we need this part?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
