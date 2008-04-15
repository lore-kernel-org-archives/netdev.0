From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 19:58:31 +0200
Message-ID: <200804151958.32805.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <20080415153408.GB7996@kroah.com> <1208276688.20681.71.camel@FWR-FLAB>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Filip Aben <f.aben@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:33700 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbYDOR67 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 13:58:59 -0400
In-Reply-To: <1208276688.20681.71.camel@FWR-FLAB>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 15. April 2008 18:24:48 schrieb Filip Aben:
> > I'm also a bit concerned about the special "set radio" ioctl as wel=
l.
> > Filip, what uses that ioctl? =C2=A0If it's really necessary, can't =
a sysfs
> > file do the same thing?
>=20
> Currently I don't think anybody uses it for Linux. I added it because
> our non-Linux drivers had this functionality. It's used for example b=
y
> our connection managers/tools to disable the RF-part when the laptop
> goes to sleep ( but keeps the USB bus powered&suspended ). This is a
> requirement for quite some operators.
> But yes, I suppose the same could be done through sysfs.

No, the correct way to do this is to support rfkill. I'll have a look
at that.

	Regards
		Oliver

