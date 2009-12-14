From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: When is the TCP Timestamp set?
Date: Mon, 14 Dec 2009 19:40:56 +0100
Message-ID: <9E2EAFB6-C358-4DDA-A8FC-5C8069465EA9@cs.uni-bonn.de>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:57224 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbZLNSzY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 13:55:24 -0500
Received: from [10.0.1.10] (dslb-084-063-021-035.pools.arcor-ip.net [84.63.21.35])
	by postfix.iai.uni-bonn.de (Postfix) with ESMTP id 17CF35C83E
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2009 19:40:57 +0100 (MET)
	(envelope-from schneid5@cs.uni-bonn.de)
	(envelope-to netdev@vger.kernel.org) (1)
	(internal use: ta=1, tu=1, te=1, am=P, au=schneid5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm programming on a version of TCP-AP for the linux-kernel which delays the TCP-Packets so there is a little space inbetween the sent packets... The delaying of the packages is working as expected. Unfortunately I seem to be delaying the packets after the point where the timestamp is set for the calculation of the roundtrip time. Since I also need the correct RTT-values for the packets, I need to fix this problem.

Until now, I haven't been able to find the point in the TCP-Code where the timestamp for the RTT calculation is set, so I was hoping someone on the Mailinglist could give me a hint which function is setting the timestamp.

Thank you for your help!

Tim Schneider