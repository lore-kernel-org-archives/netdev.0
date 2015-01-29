From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 92281] New: Raspberry Pi crashes under network load
Date: Thu, 29 Jan 2015 13:36:00 +0000
Message-ID: <20150129133600.315acbd5@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58043 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757301AbbA2NgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 08:36:09 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so39138791pab.5
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 05:36:09 -0800 (PST)
Received: from uryu.home.lan ([144.49.132.22])
        by mx.google.com with ESMTPSA id ta2sm7961304pab.5.2015.01.29.05.36.07
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 05:36:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 29 Jan 2015 05:26:08 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 92281] New: Raspberry Pi crashes under network load


https://bugzilla.kernel.org/show_bug.cgi?id=92281

            Bug ID: 92281
           Summary: Raspberry Pi crashes under network load
           Product: Networking
           Version: 2.5
    Kernel Version: Linux raspberrypi 3.12.35+ #730 PREEMPT Fri Dec 19
                    18:31:24 GMT 2014 armv6l
          Hardware: ARM
                OS: Linux
              Tree: PREEMPT_RT
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: morphex@gmail.com
        Regression: No

Created attachment 165141
  --> https://bugzilla.kernel.org/attachment.cgi?id=165141&action=edit
First kernel panic

I've setup a Raspberry PI as a simple router, which connects to a WiFi access
point. My desktop is then connected to the RPI using an ethernet cable, and the
Raspberry Pi has an USB Ethernet dongle.

I've attached pictures of the screen on two different kernel panics.

Here's the USB setup:

Bus 001 Device 002: ID 05e3:0606 Genesys Logic, Inc. USB 2.0 Hub / D-Link
DUB-H4 USB 2.0 Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 003: ID 0bda:8176 Realtek Semiconductor Corp. RTL8188CUS 802.11n
WLAN Adapter
Bus 001 Device 004: ID 09da:054f A4 Tech Co., Ltd 
Bus 001 Device 005: ID 0fe6:9700 Kontron (Industrial Computer Source / ICS
Advent) DM9601 Fast Ethernet Adapter

-- 
You are receiving this mail because:
You are the assignee for the bug.
