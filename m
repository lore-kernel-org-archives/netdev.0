From: "Pantelis Koukousoulas" <pktoss@gmail.com>
Subject: Belkin F5D5055 not really working with the asix driver
Date: Tue, 4 Nov 2008 11:31:48 +0200
Message-ID: <1295ed070811040131p9170c37r5435750fa17a6f43@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.156]:59079 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbYKDJbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 04:31:49 -0500
Received: by po-out-1718.google.com with SMTP id y22so11286901pof.1
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2008 01:31:48 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I got a belkin f5d5055 usb 2.0 gigabit adapter that should be
supported by usbnet + the asix driver, still although recognized it
doesn't actually work. More specifically, the card is recognized, the
interface is created and brought up etc only no packets flow from/to
the device.

I tried the exact same card, cable and router combination with windows
and it works fine (ping, dhcp everything) so I suspect the driver
might be the problem.

I recompiled with debug information enabled and I attach the trace,
hoping it will help.
I can also provide usbmon traces and a usbsnoop trace from the windows
machine where it works if needed.

Unfortunately I don't have the time to dig through the datasheets/code
to fix the problem myself :(

Thanks in advance.

P.s., Please CC me in any replies since I 'm not subscribed in this list
