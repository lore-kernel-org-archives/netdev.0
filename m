From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 0/7] USB: don't recover device if suspend fails in
 system sleep
Date: Fri, 8 Mar 2013 07:24:01 +0800
Message-ID: <20130307232401.GC10304@kroah.com>
References: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
 <20130307.152807.2038557949816610391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ming.lei@canonical.com, jkosina@suse.cz, stern@rowland.harvard.edu,
	oneukum@suse.de, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-input@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35363 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758218Ab3CGXYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 18:24:40 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so719946pbc.25
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 15:24:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130307.152807.2038557949816610391.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 03:28:07PM -0500, David Miller wrote:
> From: Ming Lei <ming.lei@canonical.com>
> Date: Fri,  8 Mar 2013 00:15:17 +0800
>=20
> > This patch adds comments on interface driver suspend callback
> > to emphasize that the failure return value is ignored by
> > USB core in system sleep context, so do not try to recover
> > device for this case, otherwise the recovery things may confuse
> > resume().
> >=20
> > Also fixes the USB serial, HID and several usbnet drivers
> > which may recover device in suspend failure path of system sleep.
> >=20
> > v2:
> > 	- improve comments on suspend callback as suggested by Alan
> > 	- update kerneldoc for usb_suspend_both as suggested by Alan
> > 	- remove previous check of PMSG_IS_AUTO(message) in cdc_mbim/
> > 	qmi_wwan and add comments on suspend failure case, since Bj=F8rn
> > 	doesn't like the check.
> > 	- add comments on smsc95xx/smsc75xx
> > v1:
> >         - fix compile failure
> >         - add comments about handling suspend failure in resume()
>=20
> Feel free to merge this via the USB tree and to add my ACK to the
> networking driver bits:
>=20
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, I will do that.

greg k-h
