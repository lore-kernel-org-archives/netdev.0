From: hayeswang <hayeswang@realtek.com>
Subject: RE: RTL8153 fails to get link after applying c7de7dec2 to 3.8 kernel
Date: Tue, 11 Feb 2014 10:36:48 +0800
Message-ID: <B88F103D217C4AF0B5D7AD58214655C6@realtek.com.tw>
References: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <inky.yoo@samsung.com>, 'netdev' <netdev@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>
To: 'Grant Grundler' <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:48872 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaBKCg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 21:36:56 -0500
In-Reply-To: <CANEJEGtzUF+rdSqgTHL0BmsDbCeoWki=aAWZwSx-dZ24jQ=nVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Grant Grundler [mailto:grundler@google.com] 
> Sent: Tuesday, February 11, 2014 9:39 AM
> To: Hayes Wang
> Cc: inky.yoo@samsung.com; netdev; David Miller
> Subject: RTL8153 fails to get link after applying c7de7dec2 
> to 3.8 kernel
> 
> Hi Hayes,
> "r8152: ecm and vendor modes coexist" patch prevents RTL8153 device
> from establishing a link in the backport I've worked on for
> chromeos-3.8 kernel. IIRC, r815x driver claims this device. Without
> this patch, r8152 is able to establish a link with RTL8153 device.
> 
> This was the last patch in the series of 40 patches that I
> cherry-picked and r8152 driver seems to "basically" work WITHOUT this
> last patch.  I've not tested much yet...but DHCP worked and I'm able
> to run netperf tests. I've not investigated why this patch fails and
> probably won't.
> 
> If you have opportunity, can you confirm RTL8153 devices work for you
> with any recent upstream kernel?

I had tested the patch before I sent it, and I didn't see any problem.
I would test the RTL8153 again with kernel 3.14-RC2.

Does it work if you unplug and plug the dangle again?
 
Best Regards,
Hayes
