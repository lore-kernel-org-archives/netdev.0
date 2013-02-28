From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 54021] No internet with kernel 3.7 or 3.8 with LAN
Date: Thu, 28 Feb 2013 08:42:28 -0800
Message-ID: <20130228084228.0303d070@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:40483 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758867Ab3B1Qmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 11:42:31 -0500
Received: by mail-pb0-f51.google.com with SMTP id un15so1165544pbc.24
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 08:42:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 27 Feb 2013 11:39:28 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 54021] No internet with kernel 3.7 or 3.8 with LAN


https://bugzilla.kernel.org/show_bug.cgi?id=54021


Otamay <Matt.Pikaflash@gmail.com> changed:

           What    |Removed                     |Added
----------------------------------------------------------------------------
                 CC|                            |Matt.Pikaflash@gmail.com




--- Comment #11 from Otamay <Matt.Pikaflash@gmail.com>  2013-02-27 19:38:48 ---
I have the same problem, with a similar ethernet controller, an Atheros AR8152
v2.0 (same module, atl1c)

rchavez-iron rchavez # lspci -d 1969:2062
02:00.0 Ethernet controller: Atheros Communications Inc. AR8152 v2.0 Fast
Ethernet (rev c1)

Kernel problems:

3.6.11 does works
3.7.0  does not work
3.7.2  does not work
3.7.3  does not work
3.8.0  does not work

I've reverted all linux/drivers/net/ethernet/atheros/atl1c/* files from 3.7.0
kernel to 3.6.11 and didn't work. I think this could be related to the
networking regressions from 3.7 .

Related problem:
http://forums.gentoo.org/viewtopic-t-949168-highlight-.html

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
