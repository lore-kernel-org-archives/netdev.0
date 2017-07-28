From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rt2x00: make const array glrt_table static
Date: Fri, 28 Jul 2017 15:01:30 +0000 (UTC)
Message-ID: <20170728150130.336D06095E@smtp.codeaurora.org>
References: <20170711114733.15387-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        linux-wireless@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56270 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbdG1PBb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:01:31 -0400
In-Reply-To: <20170711114733.15387-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin Ian King <colin.king@canonical.com> wrote:

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
> Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>

Patch applied to wireless-drivers-next.git, thanks.

17830147c40a mwifiex: fix spelling mistake: "Insuffient" -> "Insufficient"

-- 
https://patchwork.kernel.org/patch/9834559/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
