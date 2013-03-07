From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/7] USB: don't recover device if suspend fails in
 system sleep
Date: Thu, 07 Mar 2013 15:28:07 -0500 (EST)
Message-ID: <20130307.152807.2038557949816610391.davem@davemloft.net>
References: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, jkosina@suse.cz,
	stern@rowland.harvard.edu, oneukum@suse.de, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: ming.lei@canonical.com
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ming Lei <ming.lei@canonical.com>
Date: Fri,  8 Mar 2013 00:15:17 +0800

> This patch adds comments on interface driver suspend callback
> to emphasize that the failure return value is ignored by
> USB core in system sleep context, so do not try to recover
> device for this case, otherwise the recovery things may confuse
> resume().
>=20
> Also fixes the USB serial, HID and several usbnet drivers
> which may recover device in suspend failure path of system sleep.
>=20
> v2:
> 	- improve comments on suspend callback as suggested by Alan
> 	- update kerneldoc for usb_suspend_both as suggested by Alan
> 	- remove previous check of PMSG_IS_AUTO(message) in cdc_mbim/
> 	qmi_wwan and add comments on suspend failure case, since Bj=F8rn
> 	doesn't like the check.
> 	- add comments on smsc95xx/smsc75xx
> v1:
>         - fix compile failure
>         - add comments about handling suspend failure in resume()

=46eel free to merge this via the USB tree and to add my ACK to the
networking driver bits:

Acked-by: David S. Miller <davem@davemloft.net>
--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
