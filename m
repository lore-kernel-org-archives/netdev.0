From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] wireless: iwlegacy:  make const array static to shink
 object code size Content-Type: text/plain; charset="utf-8"
 Content-Transfer-Encoding: 8bit
Date: Fri, 22 Sep 2017 11:56:10 +0200
Message-ID: <20170922095609.GA27551@redhat.com>
References: <20170921225630.21916-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170921225630.21916-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2017 at 11:56:30PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate const array ac_to_fifo on the stack in an inlined
> function, instead make it static.  Makes the object code smaller
> by over 800 bytes:
> 
>    text	   data	    bss	    dec	    hex	filename
>  159029	  33154	   1216	 193399	  2f377	4965-mac.o
> 
>    text	   data	    bss	    dec	    hex	filename
>  158122	  33250	   1216	 192588	  2f04c	4965-mac.o
> 
> (gcc version 7.2.0 x86_64)
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Content type information was added at the end of the topic, but
I think Kalle can fix that when he will be committing the patch.

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
