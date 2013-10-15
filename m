From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH] net: qmi_wwan: Olivetti Olicard 200 support
Date: Tue, 15 Oct 2013 18:07:52 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1310151806230.12061@eeeadesso>
References: <1381842408-10800-1-git-send-email-mrkiko.rs@gmail.com> <1381842408-10800-2-git-send-email-mrkiko.rs@gmail.com> <1381848597.25397.4.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: gregkh@linuxfoundation.org, davem@davemloft.net, bjorn@mork.no,
	christian.schmiedl@gemalto.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonella Pellizzari <anto.pellizzari83@gmail.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381848597.25397.4.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

:) I'm very happy you got it working.
The firmware of our device seems so fragile still - and several QMI calls can 
bring it to a crashing state, especially when asking a network scan to the NAS 
service.


On Tue, 15 Oct 2013, Dan Williams wrote:

==Date: Tue, 15 Oct 2013 09:49:57 -0500
==From: Dan Williams <dcbw@redhat.com>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: gregkh@linuxfoundation.org, davem@davemloft.net, bjorn@mork.no,
==    christian.schmiedl@gemalto.com, linux-usb@vger.kernel.org,
==    netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
==    Antonella Pellizzari <anto.pellizzari83@gmail.com>
==Subject: Re: [PATCH] net: qmi_wwan: Olivetti Olicard 200 support
==
==On Tue, 2013-10-15 at 15:06 +0200, Enrico Mioso wrote:
==> This is a QMI device, manufactured by TCT Mobile Phones.
==> A companion patch blacklisting this device's QMI interface in the option.c
==> driver has been sent.
==> 
==> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
==> Signed-off-by: Antonella Pellizzari <anto.pellizzari83@gmail.com>
==
==Good find.  For the record, mine has:
==
==PX1522E16X  1  [Oct 15 2010 02:00:00]
==
==	ctl (1.4)
==	wds (1.8)
==	dms (1.3)
==	nas (1.2)
==	qos (1.2)
==	wms (1.1)
==	pds (1.4)
==	auth (1.0)
==	voice (1.0)
==	cat2 (1.1)
==
==Tested-by: Dan Williams <dcbw@redhat.com>
==
==> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
==> index 3d6aaf7..818ce90 100644
==> --- a/drivers/net/usb/qmi_wwan.c
==> +++ b/drivers/net/usb/qmi_wwan.c
==> @@ -714,6 +714,7 @@ static const struct usb_device_id products[] = {
==>  	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
==>  	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
==>  	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
==> +	{QMI_FIXED_INTF(0x0b3c, 0xc005, 6)},    /* Olivetti Olicard 200 */
==>  	{QMI_FIXED_INTF(0x1e2d, 0x0060, 4)},	/* Cinterion PLxx */
==>  
==>  	/* 4. Gobi 1000 devices */
==
==
==
