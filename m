From: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv2] hso: fix disable_net
Date: Thu, 25 Nov 2010 17:01:06 +0100
Message-ID: <1290700866.2112.60.camel@filip-linux>
References: <1290692450.2112.21.camel@filip-linux>
	 <AANLkTikODWoXB1PmB+SFbFWenYm_-o+RJ+czK9LnaXmn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pki-/L4m51SJ8HhmR6Xm/wNWPw@public.gmane.org
To: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikODWoXB1PmB+SFbFWenYm_-o+RJ+czK9LnaXmn-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-11-25 at 16:03 +0100, Johan Hovold wrote:
> On Thu, Nov 25, 2010 at 2:40 PM, Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org> wrote:
> > The HSO driver incorrectly creates a serial device instead of a net
> > device when disable_net is set. It shouldn't create anything for the
> > network interface.
> >
> > Signed-off-by: Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> 
> Please add the appropriate Reported-by-tags as well, e.g.
> 
> Reported-by: Piotr Isajew <pki-/L4m51SJ8HhmR6Xm/wNWPw@public.gmane.org>
> Reported-by: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I would have gladly done so if you included that in your comment on the
previous patch :)

> 
> As this patch is meant to fix a driver crash, perhaps it should be marked for
> stable as well?
> 

I don't think it's that critical: it only applies to people explicitly
loading the module with disable_net set. But feel free to queue it up
for stable.

Thanks,

Filip-



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
