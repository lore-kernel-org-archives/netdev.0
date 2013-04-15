From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 56611] New: Ethernet not working with ac adapter on lenovo
 t530
Date: Mon, 15 Apr 2013 08:26:23 -0700
Message-ID: <20130415082623.58f6389e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: E1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62281 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069Ab3DOP0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 11:26:51 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so2607747pad.2
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 08:26:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 14 Apr 2013 22:52:37 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 56611] New: Ethernet not working with ac adapter on lenovo t530


https://bugzilla.kernel.org/show_bug.cgi?id=56611

           Summary: Ethernet not working with ac adapter on lenovo t530
           Product: Networking
           Version: 2.5
    Kernel Version: 3.8
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: gmiramir@gmail.com
        Regression: Yes


Created an attachment (id=98691)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=98691)
kernel-config-x86_64-3.7.10-gentoo-r1-v2

with kernel 3.8 and the associated power can not connect to the network, if you
switch to battery it works fine. With the 3.7 kernel is always on. Wifi works
fine on both version kernel.

distributiv: gentoo
connection manager: wicd-1.7.2.4
configs kernel in attachments

lspci:
00:00.0 Host bridge: Intel Corporation 3rd Gen Core processor DRAM Controller
(rev 09)
00:02.0 VGA compatible controller: Intel Corporation 3rd Gen Core processor
Graphics Controller (rev 09)
00:14.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family
USB xHCI Host Controller (rev 04)
00:16.0 Communication controller: Intel Corporation 7 Series/C210 Series
Chipset Family MEI Controller #1 (rev 04)
00:16.3 Serial controller: Intel Corporation 7 Series/C210 Series Chipset
Family KT Controller (rev 04)
00:19.0 Ethernet controller: Intel Corporation 82579LM Gigabit Network
Connection (rev 04)
00:1a.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family
USB Enhanced Host Controller #2 (rev 04)
00:1b.0 Audio device: Intel Corporation 7 Series/C210 Series Chipset Family
High Definition Audio Controller (rev 04)
00:1c.0 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI
Express Root Port 1 (rev c4)
00:1c.1 PCI bridge: Intel Corporation 7 Series/C210 Series Chipset Family PCI
Express Root Port 2 (rev c4)
00:1d.0 USB controller: Intel Corporation 7 Series/C210 Series Chipset Family
USB Enhanced Host Controller #1 (rev 04)
00:1f.0 ISA bridge: Intel Corporation QM77 Express Chipset LPC Controller (rev
04)
00:1f.2 SATA controller: Intel Corporation 7 Series Chipset Family 6-port SATA
Controller [AHCI mode] (rev 04)
00:1f.3 SMBus: Intel Corporation 7 Series/C210 Series Chipset Family SMBus
Controller (rev 04)
02:00.0 System peripheral: Ricoh Co Ltd PCIe SDXC/MMC Host Controller (rev 05)
03:00.0 Network controller: Intel Corporation Centrino Ultimate-N 6300 (rev 3e)

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
