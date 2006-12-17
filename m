From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7696] New: b44 driver doesn't work under heavy
 load
Date: Sun, 17 Dec 2006 02:50:28 -0800
Message-ID: <20061217025028.0ca34e78.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:55084 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbWLQKug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Dec 2006 05:50:36 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Sun, 17 Dec 2006 02:20:59 -0800
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7696] New: b44 driver doesn't work under heavy load


http://bugzilla.kernel.org/show_bug.cgi?id=7696

           Summary: b44 driver doesn't work under heavy load
    Kernel Version: 2.6.20_rc1
            Status: NEW
          Severity: normal
             Owner: jgarzik@pobox.com
         Submitter: masterdriverz@gentoo.org
                CC: kernel@gentoo.org


First reported as a Gentoo bug[1] I also experience this problem. Under heavy
load (ie, downloading tarballs etc as opposed to browsing or irc) dmesg fills up
with these messages:

b44: eth0: Link is down.
b44: eth0: Link is up at 100 Mbps, full duplex.
b44: eth0: Flow control is off for TX and off for RX.

Also, ssh sessions cut out with 'Connection reset by peer' error, and downloads
often fail at this point.

lspci -v output:01:09.0 Ethernet controller: Broadcom Corporation BCM4401
100Base-T (rev 01)
        Subsystem: Dell Unknown device 8127
        Flags: bus master, fast devsel, latency 64, IRQ 18
        Memory at fe9fe000 (32-bit, non-prefetchable) [size=8K]
        Expansion ROM at 20080000 [disabled] [size=16K]
        Capabilities: [40] Power Management version 2

I currently have the b44 driver compiled into my kernel. The earliest kernel
I've reproduce this with is 2.6.15, though I can go back further if necessary.
This is still reproducible with 2.6.20_rc1.

[1] http://bugs.gentoo.org/show_bug.cgi?id=147722

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
