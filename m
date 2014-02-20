From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Thu, 20 Feb 2014 12:00:46 +0800
Message-ID: <FB59F84B1E5E42AA98F0906286C444DF@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com><B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw><CANEJEGtvY1v0AC7j+uo7-ZzN9YMOaE9JOtismt0ESxpVWkvHyQ@mail.gmail.com><6929A44AB95D46C6B919DDD537CDD37B@realtek.com.tw><CANEJEGtj5b6z3L1AeiqTPgVs0qCe=pv=cyRHYi04_yNXpPMOCA@mail.gmail.com><FD21003FF7E540DCA7F8F39A2BC046B4@realtek.com.tw><CANEJEGtGSHAACM=Bk0BAHrM=-1q4pHoboO5FYN7YM4wquMMmXA@mail.gmail.com><65183A93811745C58958ECBAD0B8E00F@realtek.com.tw><CANEJEGtGbVajk+GOSkRk1QXDkOOPCM8vO8VA8Zc=TEOfZDjwNQ@mail.gmail.com> <CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Inki Yoo' <inky.yoo@samsung.com>,
	'netdev' <netdev@vger.kernel.org>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60981 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaBTEBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 23:01:11 -0500
In-Reply-To: <CANEJEGsMafeZQDfnmdgmf2VN0CKrTkjVHwKTX9JHTDUUqwx0Mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler [mailto:grundler@google.com] 
> Sent: Thursday, February 20, 2014 8:08 AM
> To: hayeswang
> Cc: Inki Yoo; netdev
> Subject: Re: RTL8153 fails to get link after applying 
> c7de7dec2 to 3.8 kernel
> 
> On Fri, Feb 14, 2014 at 1:53 PM, Grant Grundler 
> <grundler@google.com> wrote:
[...]
> I will temporarily add the udev rule you previously
> posted in order to automate testing this until I can get HW that comes
> up in "vendor mode".

Excuse me if I misunderstand your meaning. Our device has two
configurations and I don't think you would get one with vendor
mode only without ECM mode. Besides, according to the information
from one of the maintainers of the kernel, when a USB device with
more than one configuration is plugged, the USB core would select
the configuration which is not vendor mode first if it exists.
Therefore, it is reasonably considered that the configuration 2
would be set by default for our device if you do nothing.

 
Best Regards,
Hayes
