From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: [PATCH] ath6kl: fix memory leak in ath6kl_fwlog_block_read()
Date: Mon, 16 Apr 2012 09:07:49 +0300
Message-ID: <4F8BB735.4040409@qca.qualcomm.com>
References: <alpine.LNX.2.00.1204112239070.2137@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Robert Love <rlove-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	ath6kl-devel <ath6kl-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org>
To: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1204112239070.2137-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/2012 11:41 PM, Jesper Juhl wrote:
> If, in
> drivers/net/wireless/ath/ath6kl/debug.c::ath6kl_fwlog_block_read(),
> the call to wait_for_completion_interruptible() returns -ERESTARTSYS
> then we'll return without freeing the (as yet unused) memory we
> allocated for 'buf' - thus leaking it.
> 
> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>

Thanks, applied to ath6kl.git.

Kalle
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
