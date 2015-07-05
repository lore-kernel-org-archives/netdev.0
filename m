From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V2] cdc_ncm: Add support for moving NDP to end of NCM
 frame
Date: Sun, 5 Jul 2015 12:21:10 +0200 (CEST)
Message-ID: <alpine.LNX.2.20.1507051219280.12595@archiso.lan>
References: <1435787748-30393-1-git-send-email-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1435787748-30393-1-git-send-email-mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When sending lots of small packets, this patch will generate an "Unable to 
handle kernel paging request" in the memset call:
ndp16 = memset(ctx->delayed_ndp16, 0, ctx->max_ndp_size);
And I don't know why.
Any comment or suggestion would be greatly apreciated.
This has been reproduced in a QEMU X86 VM, from kernel 4.0.4 to current git.
Thanks,
Enrico Mioso
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
