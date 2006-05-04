From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6484] New: dropouts with user mode PPPoE
Date: Wed, 3 May 2006 18:56:38 -0700
Message-ID: <20060503185638.10f23034.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54190 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750843AbWEDB4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 21:56:42 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k441uetH027955
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 3 May 2006 18:56:41 -0700
Received: from sony (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id k441udaZ023696
	for <netdev@vger.kernel.org>; Wed, 3 May 2006 18:56:40 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 2 May 2006 13:28:22 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6484] New: dropouts with user mode PPPoE


http://bugzilla.kernel.org/show_bug.cgi?id=6484

           Summary: dropouts with user mode PPPoE
    Kernel Version: 2.6.16 and above
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: lkml@jawad.org


Distribution: Debian
Hardware Environment: P4 Northwood, 2 GB, i875, e1000 CSA
Software Environment: pppd, rp-pppoe

Problem Description:
ADSL connection through PPPoE occasionally stalls for 30 to 50 seconds,
especially under load. During these dropouts, packets are received but none that
are supposed to be sent appear on ppp0. Ethernet interface continues to work,
telnet session to modem does not stall.

Exhibition of the bug is not affected by:
SMP or uniprocessor kernel, Hyper Threading disabled or enabled, pppd version
(tested with 2.4.2 and 2.4.4b1), rp-pppoe version (tested 3.5 & 3.8).
CPU load is probably not a factor either.

Dropouts seem to appear more frequently when the connection is under load (large
Bittorrent swarms are a good test). They can appear as soon as a few minutes
after start but it also took more than 5 hours once. Most of the time, they will
appear every half to one hour.

Problem does not occur with 2.6.15.7 or earlier. Second system with AMD64
SanDiego & NForce4 is not affected, will try to match configuration as closely
as possible and retest.
Kernel mode PPPoE using the rp-pppoe plugin does also not exhibit the bug.

2.6.17-rc3 .config:
http://jawad.org/.config

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
