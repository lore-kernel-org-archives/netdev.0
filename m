From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dccp: make const array error_code static
Date: Thu, 13 Jul 2017 09:24:44 -0700 (PDT)
Message-ID: <20170713.092444.2018465341570344249.davem@davemloft.net>
References: <20170713112224.31667-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170713112224.31667-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 13 Jul 2017 12:22:24 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate array error_code on the stack but make it static. Makes
> the object code smaller by almost 250 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>   10366	    983	      0	  11349	   2c55	net/dccp/input.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>   10161	   1039	      0	  11200	   2bc0	net/dccp/input.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
