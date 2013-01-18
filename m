From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Fri, 18 Jan 2013 20:11:25 +0100
Message-ID: <22276933.xSGyXJfOvq@linux-5eaq.site>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358519147-10073-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 18 January 2013 15:25:47 Bj=F8rn Mork wrote:
> Adding support for the MBIM mode in some Sierra Wireless devices.
>=20
> Some Sierra Wireless firmwares support CDC MBIM but have no CDC
> Union funtional descriptor. This violates the MBIM specification,
> but we can easily work around the bug by looking at the Interface
> Association Descriptor instead.  This is most likely what
> Windows uses too, which explains how the firmware bug has gone
> unnoticed until now.

Should we do this for everything CDC?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
