From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] rt2x00: make const array glrt_table static
Date: Wed, 12 Jul 2017 08:49:12 +0200
Message-ID: <20170712064911.GA2769@redhat.com>
References: <20170711114733.15387-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40354 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755903AbdGLGuP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 02:50:15 -0400
Content-Disposition: inline
In-Reply-To: <20170711114733.15387-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 11, 2017 at 12:47:33PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate array glrt_table on the stack but make it static.
> Makes the object code a smaller by over 670 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>  131772	   4733	      0	 136505	  21539	rt2800lib.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>  131043	   4789	      0	 135832	  21298	rt2800lib.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>

I wonder why compiler do not optimize by itself since array is
const, but patch is ok.

Stanislaw 
