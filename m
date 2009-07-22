From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Wed, 22 Jul 2009 10:37:06 +0200
Message-ID: <200907221137.07005.remi.denis-courmont@nokia.com>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
 <1248184373.6558.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ext Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: ext Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1248184373.6558.15.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Language: fr-FR
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 21 July 2009 16:52:53 ext Dan Williams wrote:
> > This was tested against Nokia E61, Nokia N95, and the existing Phon=
et
> > gadget function for the Linux composite USB gadget framework.
>
> Is there an example somewhere of how to use Phonet to get a mobile
> broadband connection in place of usb-serial and PPP?

Not yet, I'm afraid.

> I've read the
> Phonet protocol description and other random docs I can find, but can=
't
> figure out how that would work.  Or does "PC Suite" mode not support
> that?

PC suite does provide access to packet data. The existing pn_pep kernel=
 module=20
provides data path (IPv4 or IPv6 packets) and flow control. But GPRS co=
ntext=20
credentials, IP/DNS parameters, setup/teardown, etc, are missing. I am =
not=20
sure where the user/kernel split should be here...

I guess in a perfect world, Linux would provide a common control interf=
ace for=20
GPRS as it already does WiFi (and maybe soon will for WiMAX?). But I am=
 not=20
sure we can unify AT+PPP, Phonet, AT+Ethernet and who knows what else, =
behind=20
a common Netlink interface, especially as AT commands have always been =
done in=20
userland anyway.

Or what did you have in mind?

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
