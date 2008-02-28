From: "m. allan noah" <kitno455@gmail.com>
Subject: forcedeth kernel panic with nForce 630a on 100Mbps FD network
Date: Thu, 28 Feb 2008 15:39:58 -0500
Message-ID: <97246d0e0802281239t43d9167dwe2740ed11d1300e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:41820 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073AbYB1UkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 15:40:01 -0500
Received: by wf-out-1314.google.com with SMTP id 28so3390384wff.4
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 12:39:58 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Have two Asus M2N-VN DVI motherboards, Athlon 64 X2 5000+, 8 gigs of
ram, both running Fedora 8. with updated distro kernel
(2.6.23.15-137).

When RXing large amounts of data on a 100Meg network, i start seeing
RX errors almost immediately, seemingly always equal numbers of
rx_frame_error and rx_frame_align_error (according to ethtool -S).

Soon afterwards, the network speed drops pretty drastically, and then
stops altogether. no ping, etc. rmmod and insmod forcedeth seems to
fix things again, but if i let the scp continue against the dead card,
it will eventually kernel panic.

there is nothing unusual in syslog, and none of this happens if i
connect the two machines directly with crossover cable at 1000Meg

I have just upgraded one of the machines to vanilla 2.6.24, and i
still see the ethtool errors, and eventually the slow downs, but no
network freeze or kernel panic yet, so it looks a little better?

The machines are not going into production for a few weeks, so i
wondered if there was any use in getting you guys some debugging info,
or any hope of an updated driver to try?

allan
-- 
"The truth is an offense, but not a sin"
