From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 55951] New: usbatm BUG when killing pppd or br2684ctl
Date: Sat, 30 Mar 2013 17:06:01 -0700
Message-ID: <20130330170601.621bda4f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:40443 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615Ab3CaAGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 20:06:15 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so627626dan.38
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 17:06:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 29 Mar 2013 17:45:31 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 55951] New: usbatm BUG when killing pppd or br2684ctl


https://bugzilla.kernel.org/show_bug.cgi?id=55951

           Summary: usbatm BUG when killing pppd or br2684ctl
           Product: Networking
           Version: 2.5
    Kernel Version: 3.8.2
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: jd.girard@sysnux.pf
        Regression: Yes


Created an attachment (id=96631)
 --> (https://bugzilla.kernel.org/attachment.cgi?id=96631)
Kernel BUG

The system is an alix2d2 acting as my Internet router through an USB ADSL modem
(DLink DSL200); xusbatm is driving the modem, but it needs a patched version of
usbatm (patch was written by Roman Kagan). I've been using this setup since
November 2011 (kernel 2.6.36 or 2.6.37), regularly updating the kernel without
trouble, so I think this is a regression.

The problem only occurs when killing pppd or br2684ctl (done in a script when
connection is lost), otherwise the system works fine:
[xxxxx@ix100 ~]$ uptime 
 14:34:36 up 9 days,  8:48,  1 user,  load average: 0.20, 0.13, 0.14

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
