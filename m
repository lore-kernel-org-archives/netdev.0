From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH] TODO FLAG_POINTTOPOINT => FLAG_WWAN? usbnet/cdc_ncm:
 mark ncm devices as "mobile broadband devices" with FLAG_WWAN
Date: Wed, 1 Jun 2011 12:20:20 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E583@EXDCVYMBSTM006.EQ1STM.local>
References: <1306922913-17803-1-git-send-email-metze@samba.org>
 <1306922913-17803-2-git-send-email-metze@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stefan Metzmacher <metze@samba.org>,
	Oliver Neukum <oliver@neukum.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306922913-17803-2-git-send-email-metze@samba.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stefan Metzmacher
> Sent: Wednesday, June 01, 2011 12:09 PM


> -	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET,
> +	.flags = FLAG_WWAN | FLAG_NO_SETINT | FLAG_MULTI_PACKET,

This patch will introduce incompatibility with already existing
applications, which track usbX devices. As a result, end user
application will stop working.

cdc_ncm driver can also be used for local link terminated in device,
so wwan would be inappropriate name.

Regards,
Alexey
