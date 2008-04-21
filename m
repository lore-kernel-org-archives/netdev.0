From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 12:34:39 +0300
Message-ID: <480C5FAF.1050408@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <200804211016.02819.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:39723 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755781AbYDUJfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 05:35:33 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JnsQq-00024H-4V
	for netdev@vger.kernel.org; Mon, 21 Apr 2008 09:35:28 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 09:35:28 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 09:35:28 +0000
In-Reply-To: <200804211016.02819.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> Am Montag, 21. April 2008 03:04:21 schrieb Paulius Zaleckas:
>> -               odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
>> -                                  USB_CDC_PACKET_TYPE_DIRECTED |
>> -                                  USB_CDC_PACKET_TYPE_BROADCAST |
>> -                                  USB_CDC_PACKET_TYPE_MULTICAST;
> 
> Hi,
> 
> before you rip out the multicast stuff, do you have an idea why it was
> included in the first place? Is the device capable of operating in a
> real network topology where multicast would make sense?

It was there from the oldest version (0.6) I have, but in the dead code
as it is now. There was also a comment:
/* FIXME AJB, work out what we need to do with multicast */
It was addressed to Andrew Bird (added to CC)

IMO it doesn't make sense to do multicasting since actually it is
point-to-point and not ethernet traffic.
Currently I am studying if it is possible to convert current pseudo
ethernet interface to point-to-point one.

