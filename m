From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8kernel
Date: Mon, 3 Mar 2014 10:40:12 +0800
Message-ID: <2E323D0E3EDB4D889FDC1F6767EC256C@realtek.com.tw>
References: <D7709D6F234143CDB4D0B6B27C53D3F4@realtek.com.tw><CANEJEGuCWZSBNppE+W2_UW8mDZYQCBpsJTjfwuizjPMpY+wZzw@mail.gmail.com><6055EBDEF51C4CDDBE25766ED5CACA67@realtek.com.tw> <20140226.115831.255949929805078536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <grundler@google.com>, <inky.yoo@samsung.com>,
	<netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:59690 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbaCCCkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 21:40:21 -0500
In-Reply-To: <20140226.115831.255949929805078536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller [mailto:davem@davemloft.net] 
> Sent: Thursday, February 27, 2014 12:59 AM
> To: hayeswang@realtek.com
> Cc: grundler@google.com; inky.yoo@samsung.com; netdev@vger.kernel.org
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8kernel
[...]
> > Please contact with the person who give you the dangle.
> > You should need the another one.
> 
> This is not an appropriate response.
> 
> Your company made a chip, and people are going to repackage it and
> reuse it in their own implementations.
> 
> Sometimes they will set jumpers incorrectly, add bugs to the firmware,
> and make other mistakes.
> 
> When you are made explicitly awre of such situations, your driver
> should absolutely strive to handle that, rather than refuse to.
> 
> It is mysterious to me when a driver author behaves in such a way that
> they seem to want their driver to work on fewer instances of their
> hardware rather than support more of them.

Normally, the settings are used in Windows driver which fix the
config of the usb device. It is the known issue that the ecm mode
couldn't work with such settings. I don't sure the Samsung understand
this clearly, but our fae has notices them again to explain what
would happen. If you want to fix it, you should switch the config
to the vendor mode to let such vendor control transfers valid.
Therefore, I say it couldn't be fixed in ecm mode, and it is the
limitation of the hardware.

Although we provide the possibility of customization, we wouldn't
know which settings they would use completely. I think the tester
is asked by Samsung, so the better way is to get the device from
the Samsung.
