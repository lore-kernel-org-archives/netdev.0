From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: iwlegacy:  make const array static to shink
 object code size Content-Type: text/plain; charset="utf-8"
 Content-Transfer-Encoding: 8bit
Date: Fri, 22 Sep 2017 08:00:29 +0200
Message-ID: <1506060029.2048.9.camel@sipsolutions.net>
References: <20170921225630.21916-1-colin.king@canonical.com>
         (sfid-20170922_005652_800251_1E085F58)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921225630.21916-1-colin.king@canonical.com> (sfid-20170922_005652_800251_1E085F58)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-09-21 at 23:56 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate const array ac_to_fifo on the stack in an inlined
> function, instead make it static.  Makes the object code smaller
> by over 800 bytes:
> 
>    text	   data	    bss	    dec	    hex	
> filename
>  159029	  33154	   1216	 193399	  2f377	
> 4965-mac.o
> 
>    text	   data	    bss	    dec	    hex	
> filename
>  158122	  33250	   1216	 192588	  2f04c	
> 4965-mac.o
> 
> (gcc version 7.2.0 x86_64)

I'm curious - how did you find this?

johannes
