From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Wed, 1 Jun 2011 14:27:50 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E6F2@EXDCVYMBSTM006.EQ1STM.local>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
 <1306922913-17803-2-git-send-email-metze@samba.org>
 <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
 <4DE618B7.5070903@samba.org>
 <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E64B@EXDCVYMBSTM006.EQ1STM.local>
 <4DE6287D.5080807@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DE6287D.5080807@samba.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stefan (metze) Metzmacher [mailto:metze@samba.org]
> Sent: Wednesday, June 01, 2011 1:55 PM

> > If you use udev rules and create an alias for your device, you won't
> > be dependent on generic driver code.
> 
> Ok, do you have examples for that?

Please, read udev man pages. Rule might be as follows
KERNEL=="usb*", ATTRS{idVendor}=="04cc", ATTRS{idProduct}=="xxxx", NAME="ste_bridge0"

Regards,
alexey
