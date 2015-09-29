From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: Make mwifiex_dbg a function, reduce object size
Date: Tue, 29 Sep 2015 07:33:20 +0000 (UTC)
Message-ID: <20150929073320.9C61F140BF6@smtp.codeaurora.org>
References: <1441043205.3276.28.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441043205.3276.28.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The mwifiex_dbg macro has two tests that could be consolidated
> into a function reducing overall object size ~10KB (~4%).
> 
> So convert the macro into a function.
> 
> $ size drivers/net/wireless/mwifiex/built-in.o* (x86-64 defconfig)
>    text	   data	    bss	    dec	    hex	filename
>  233102	   8628	   4809	 246539	  3c30b	drivers/net/wireless/mwifiex/built-in.o.new
>  243949	   8628	   4809	 257386	  3ed6a	drivers/net/wireless/mwifiex/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
