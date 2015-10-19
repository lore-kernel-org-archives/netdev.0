From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 106171] New: Regression causes "ip" command to crash,
 leaving the user without any networking
Date: Sun, 18 Oct 2015 21:28:38 -0700
Message-ID: <20151018212838.552beb1d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nimrod Andy <B38611@freescale.com>,
	"Lothar =?UTF-8?B?V2HDn21hbm4=?=" <LW@KARO-electronics.de>,
	Lucas Stach <l.stach@pengutronix.de>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32804 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbbJSE22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 00:28:28 -0400
Received: by pabrc13 with SMTP id rc13so178266366pab.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 21:28:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Freescale driver bug.


Begin forwarded message:

Date: Mon, 19 Oct 2015 02:14:45 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 106171] New: Regression causes "ip" command to crash, leaving the user without any networking


https://bugzilla.kernel.org/show_bug.cgi?id=106171

            Bug ID: 106171
           Summary: Regression causes "ip" command to crash, leaving the
                    user without any networking
           Product: Networking
           Version: 2.5
    Kernel Version: 4.2.0
          Hardware: ARM
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: justincase@yopmail.com
        Regression: No

Created attachment 190481
  --> https://bugzilla.kernel.org/attachment.cgi?id=190481&action=edit
Process ip (pid: 252, stack limit = 0xed7a4220)  Stack: (0xed7a5a58 to
0xed7a6000)

Between kernel version 4.1.7 and 4.2.0 something caused networking to be left
non-functioning. I can confirm the bug is still in mainline 4.2.3.

Attached is the stack trace showing up during boot of the device with 4.2.3
kernel. I have since regressed to 4.1.x and networking works fine again.

I had one other user confirm this bug via Freenode IRC.

-- 
You are receiving this mail because:
You are the assignee for the bug.
