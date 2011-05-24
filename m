From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4] CDC NCM: release interfaces fix in unbind()
Date: Tue, 24 May 2011 13:28:43 -0400 (EDT)
Message-ID: <20110524.132843.2135584228932107607.davem@davemloft.net>
References: <1306250773-9177-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org
To: alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1306250773-9177-1-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 24 May 2011 17:26:13 +0200

> Changes:
> - claim slave/data interface during bind() and release
>  interfaces in unbind() unconditionally
> - in case of error during bind(), release claimed data
>  interface in the same function
> - remove obsolited "*_claimed" entries from driver context
> 
> Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
