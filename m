From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: "kernel:nf_ct_icmp: bad HW ICMP checksum" too noisy
Date: Thu, 15 Apr 2010 16:25:44 +0200
Message-ID: <m31vegztav.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60308 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754235Ab0DOO0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 10:26:01 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1O2Q0y-0005JA-UD
	for netdev@vger.kernel.org; Thu, 15 Apr 2010 16:25:56 +0200
Received: from 94.127.50.7 ([94.127.50.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:25:56 +0200
Received: from benny+usenet by 94.127.50.7 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:25:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Would it be possible to lower the log level of "kernel:nf_ct_icmp: bad
HW ICMP checksum" so that they don't show up on the console? Obviously I
could configure rsyslog to never send anything to the console, but then
I might miss something which is actually critical.

It's obviously nice to know about corrupted ICMP on a controlled LAN,
but on the open Internet you can't really do anything about it.


/Benny


