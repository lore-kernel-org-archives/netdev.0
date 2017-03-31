From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [PATCHv3] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 31 Mar 2017 11:39:10 +0200
Message-ID: <1490953150.30466.11.camel@suse.com>
References: <1490941561-20502-1-git-send-email-gerg@linux-m68k.org>
         <8737dt25od.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
        Greg Ungerer <gerg-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8737dt25od.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 31.03.2017, 10:48 +0200 schrieb Bjørn Mork:
> You get *all* the "0" line drivers for free, not only "qmi_wwan".  No
> code changes needed, except for adding the single .ndo line to drivers
> overriding the usbnet default net_device_ops. And even that only applies
> to a few of them.  Most will be OK if you just change the usbnet
> default.
> 
> I don't think the size of a complete series will be terrifying to
> anyone.

It would really be nice to do that.
However, if you really don't want to do it, well you wrote
a patch. But I am afraid dropping the error count is not acceptable.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
