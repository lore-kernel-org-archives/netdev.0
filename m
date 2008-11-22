From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/3] driver/net/*: remove redundant argument comments
Date: Fri, 21 Nov 2008 23:55:27 -0800
Message-ID: <9929d2390811212355j635e0e8iee0e53678efc5f09@mail.gmail.com>
References: <4927b790.0e0d6e0a.65cc.ffffcb05@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Qinghuang Feng" <qhfeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f11.google.com ([209.85.217.11]:46088 "EHLO
	mail-gx0-f11.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbYKVHz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:55:29 -0500
Received: by gxk4 with SMTP id 4so1155643gxk.13
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 23:55:27 -0800 (PST)
In-Reply-To: <4927b790.0e0d6e0a.65cc.ffffcb05@mx.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 11:40 PM, Qinghuang Feng
<qhfeng.kernel@gmail.com> wrote:
> remove redundant argument comments in files of drivers/net/*
>
> Signed-off-by: Qinghuang Feng <qhfeng.kernel@gmail.com>
> ---
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 91795f7..122539a 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -345,7 +345,6 @@ no_buffers:
>  /**
>  * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
>  * @adapter: address of board private structure
> - * @rx_ring: pointer to receive ring structure
>  * @cleaned_count: number of buffers to allocate this pass
>  **/
>

NAK - rather than removing documentation, I would suggest improving
the documentation.  Your suggested patch removes lines in the function
headers which can be (if not already) in documentation.  Specifically,
the function header comments for Intel drivers was written in such a
way that it can be parsed out by the kernel documentation scripts to
create an API document.

I would agree that "@rx_ring: pointer to receive ring structure" is
probably not the best documentation, but rather than removing it, I
would suggest improving it.


-- 
Cheers,
Jeff
