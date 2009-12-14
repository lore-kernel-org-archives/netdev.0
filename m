From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: When is the TCP Timestamp set?
Date: Mon, 14 Dec 2009 19:37:28 +0100
Message-ID: <18E6EC34-EECB-42E8-8911-54A0EF31D10E@cs.uni-bonn.de>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:56567 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530AbZLNSpY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 13:45:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm programming on a version of TCP-AP for the linux-kernel which delays the TCP-Packets so there is a little space inbetween the sent packets... The delaying of the packages is working as expected. Unfortunately I seem to be delaying the packets after the point where the timestamp is set for the calculation of the roundtrip time. Since I also need the correct RTT-values for the packets, I need to fix this problem.

Until now, I haven't been able to find the point in the TCP-Code where the timestamp for the RTT calculation is set, so I was hoping someone on the Mailinglist could give me a hint which function is setting the timestamp.

Thank you for your help!

Tim Schneider