From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 108201] New: Can connect with Huawei E3131-s2 (Hi-Link) 3G
 modem only after reboot.
Date: Fri, 20 Nov 2015 08:22:07 -0800
Message-ID: <20151120082207.6bfdd28c@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34754 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759269AbbKTQV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:21:56 -0500
Received: by padhx2 with SMTP id hx2so120724566pad.1
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 08:21:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Appears to be a cdc_ether driver bug. See Bugzilla for more followup info

Begin forwarded message:

Date: Fri, 20 Nov 2015 11:11:26 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 108201] New: Can connect with Huawei E3131-s2 (Hi-Link) 3G modem only after reboot.


https://bugzilla.kernel.org/show_bug.cgi?id=108201

            Bug ID: 108201
           Summary: Can connect with Huawei E3131-s2 (Hi-Link) 3G modem
                    only after reboot.
           Product: Networking
           Version: 2.5
    Kernel Version: 4.1.12-1-default
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: cameronpoe@poczta.fm
        Regression: No

When I start (boot) the system from shutdown state I can't connect to Internet
because there is no network connection in pop-up network plasma menu (close to
clock in right bottom of the screen) in new openSUSE Leap 42.1 with KDE 5.

When I shutdown the laptop and start again (boot again) it still doesn't
connect (no connection available), but if I restart (reboot) the system the
connection works (shows in plasma networking pop-up menu).

>From what I can see in journalctl when I boot the laptop for the 1st time the
system recognizes this modem as memory stick and there are errors in
journalctl:

NetworkManager[878]: <warn>  (eth1): failed to find device 4 'eth1' with udev
NetworkManager[878]: <info>  (eth1): new Ethernet device (carrier: OFF, driver:
'cdc_ether', ifindex: 4)
kernel: cdc_ether 3-1:1.0 eth1: register 'cdc_ether' at usb-0000:00:12.2-1, CDC
Ethernet Device, 58:2c:80:13:92:63
kernel: usbcore: registered new interface driver cdc_ether
NetworkManager[878]: <info>  (eth1): device state change: unmanaged ->
unavailable (reason 'managed') [10 20 2]
kernel: cdc_ether 3-1:1.0 eth1: kevent 12 may have been dropped
NetworkManager[878]: <info>  (eth1): link connected
NetworkManager[878]: <info>  (eth1): device state change: unavailable ->
disconnected (reason 'none') [20 30 0]

...but when I reboot the laptop the system recognizes it as modem strait away
and there are no "failed" nor "dropped" messages. I will attach 2 files with
journalctl from the 1st boot and the reboot.

I have always been installing the Huawei E3131-s2 (Hi-Link) from Linux driver
attached in the modem's internal memory and it always worked, but now when I
reinstalled the openSUSE system to newer version 42.1 there was an "failed"
error with runmbbservice so I deactivated it. Anyway, the connection did not
work either.

Another thing - when I unplug the modem and plug it back in it fails again and
the connection vanishes (doesn't show up when I plug modem back) and I have to
reboot the system to be able to connect to the Internet.

I is annoying to always boot the system and reboot in order to connect t the
Internet :( So, can anyone fix this please?

-- 
You are receiving this mail because:
You are the assignee for the bug.
