From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 65261] New: Packet loss or excessive packet delay
 repeatedly for some seconds
Date: Wed, 20 Nov 2013 12:23:16 -0800
Message-ID: <20131120122316.77ce76c5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:57775 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab3KTUXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:23:20 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so1587167pad.17
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:23:19 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id qv8sm40007593pbc.31.2013.11.20.12.23.18
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 12:23:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 20 Nov 2013 05:57:59 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 65261] New: Packet loss or excessive packet delay repeatedly for some seconds


https://bugzilla.kernel.org/show_bug.cgi?id=65261

            Bug ID: 65261
           Summary: Packet loss or excessive packet delay repeatedly for
                    some seconds
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.19
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: arno@wagner.name
        Regression: No

Created attachment 115261
  --> https://bugzilla.kernel.org/attachment.cgi?id=115261&action=edit
Kernel config 3.10.19

I recently upgraded my development-server/firewall/NAT-box from 3.10.17 to
3.10.19. Since then I noticed increased DNS lookup failures on a connected
Windows box and occasional slow updates on putty-SSH logins when scrolling in
an editor (joe, takes something like an estimated 100-300ms for screen
updates). These update delays are repeatable for something like 10-20 seconds
or more, e.g. inserting a line and then deleting again, then vanish. The delays
make remote editing hard to do when they happen. The DNS lookup failures are
really annoying. 

I have not found a way to reliably trigger the problem.

Going back to 3.10.17 fixed the issue as far as I can tell. (Several hours
editing source code without it showing up.) The only change between the two
configurations was that I added the scsi CDROM driver (which should not be able
to cause this?).

The network connection has an iptables "all pass" on the server side for the
affected connection. The client side is a Win7 machine. The network link is GbE
with 2 Switches in there. No packet loss on ping/ping -f. Network hardware is 
Intel 82574L Gigabit card on both sides.

-- 
You are receiving this mail because:
You are the assignee for the bug.
