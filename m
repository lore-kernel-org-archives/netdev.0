From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Tue, 21 Jul 2009 17:34:23 +0200
Message-ID: <1248190463.28545.13.camel@violet>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	 <1248184373.6558.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248184373.6558.15.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dan,

> > Many Nokia handsets support a Phonet interface to the cellular modem
> > via a vendor-specific USB interface. CDC Phonet follows the
> > Communications Device Class model, with one control interface, and
> > and a pair of inactive and active data alternative interface. The later
> > has two bulk endpoint, one per direction.
> > 
> > This was tested against Nokia E61, Nokia N95, and the existing Phonet
> > gadget function for the Linux composite USB gadget framework.
> 
> Is there an example somewhere of how to use Phonet to get a mobile
> broadband connection in place of usb-serial and PPP?  I've read the
> Phonet protocol description and other random docs I can find, but can't
> figure out how that would work.  Or does "PC Suite" mode not support
> that?

I talked with Remi about it and he told me that currently there is no
public example on how to do it. Also it involves a bit more event
handling and other details via ISI modem library. At some point we will
have an example inside oFono on how to do it, but not right now.

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
