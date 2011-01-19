From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv2] USB CDC NCM: tx_fixup() race condition fix
Date: Tue, 18 Jan 2011 16:14:49 -0800 (PST)
Message-ID: <20110118.161449.70210939.davem@davemloft.net>
References: <1295284045-9310-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1295284045-9310-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 17 Jan 2011 18:07:25 +0100

> - tx_fixup() can be called from either timer callback or from xmit()
>   in usbnet, so spinlock is added to avoid concurrency-related problem.
> - minor correction due to checkpatch warning for some line over 80
>   chars after previous patch was applied.
> 
> Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>

Applied, thanks a lot.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
