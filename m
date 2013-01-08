From: "Wei Shuai" <cpuwolf@gmail.com>
Subject: net: usb: cdc_ncm: add support  IFF_NOARP
Date: Tue, 8 Jan 2013 21:14:47 +0800
Message-ID: <001601cdeda2$2547a6b0$6fd6f410$@com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>
To: "'Greg Kroah-Hartman'" <gregkh@linuxfoundation.org>,
	"'Alexey Orishko'" <alexey.orishko@stericsson.com>,
	"'Hans Petter Selasky'" <hans.petter.selasky@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:38077 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755808Ab3AHNOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 08:14:55 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexey,
	Recently I met a Modem which cannot do ARP. But I found our
cdc_ncm_bind() function cannot handle this special case. Do you have any
plan to handle it?


static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
{
	...
 	/*  cannot do ARP */
 	dev->net->flags |= IFF_NOARP;
	...
}
