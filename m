From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2 2/2] USB CDC NCM host driver
Date: Thu, 25 Nov 2010 21:59:51 -0800
Message-ID: <20101125215951.5a77e811@nehalam>
References: <1290694472-2680-1-git-send-email-alexey.orishko@stericsson.com>
	<1290694472-2680-2-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh-l3A5Bk7waGM@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1290694472-2680-2-git-send-email-alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Nov 2010 15:14:32 +0100
Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> +/*
> + * We need to align the beginning of the IP packet (not the Ethernet framing).
> + * The following macro aligns the given offset to the given remainder
> + * and modulus, which must be power of two.
> + */
> +#define	CDC_NCM_ALIGN(rem, offset, mod)	\
> +	((long)(((long)(rem)) - ((long)((-(long)(offset)) & (-(long)(mod))))))

Isn't existing PTR_ALIGN macro sufficient?

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
