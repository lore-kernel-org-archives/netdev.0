From: =?ISO-8859-1?Q?=22L=2E_Alberto_Gim=E9nez=22?=
	<agimenez@sysvalve.es>
Subject: Re: [PATCH Resubmission] drivers/net/usb: Add new driver ipheth
Date: Tue, 13 Apr 2010 21:03:25 +0200
Message-ID: <4BC4BFFD.9040802@sysvalve.es>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>	<1270678281-20750-1-git-send-email-agimenez@sysvalve.es> <20100413.011540.115903049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	gregkh@suse.de, jonas.sjoquist@ericsson.com,
	steve.glendinning@smsc.com, torgny.johansson@gmail.com,
	dbrownell@users.sourceforge.net, omar.oberthur@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from capside.net ([81.19.98.74]:44769 "EHLO eul0600410.eu.verio.net"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751385Ab0DMTEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Apr 2010 15:04:33 -0400
In-Reply-To: <20100413.011540.115903049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Unless you add a rule to drivers/net/Makefile, the build won't
> actually get to your driver unless one of the other USB networking
> devices are configured.
>  =20

Hi David,

Thanks for the info. I didn't know that I had to add an entry on the=20
upper level Makefile. I guess that something like=20
obj-$(CONFIG_USB_IPHETH) +=3D usb/ should be enough? (I got it from the=
=20
other USB net drivers).

I won't be able to work on it today, I've been very busy today and can'=
t=20
look into this, but I've not given up :)

> Please fix this up and resubmit.=20

I have also in my queue a patch sent from upstream to fix the latest=20
issues pointed out by Roland Dreier, and I need to test it a little bit=
=20
more.

Thanks for your comments and patience!


Best regards,
L. Alberto Gim=E9nez
