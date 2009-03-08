From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: HTB vs HFSC, HTB is highly inaccurate
Date: Sun, 8 Mar 2009 20:45:39 +0200
Message-ID: <200903082045.39083.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42648 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542AbZCHSpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 14:45:52 -0400
Received: from adminos.visp.net.lb (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 3587E1A4A9A
	for <netdev@vger.kernel.org>; Sun,  8 Mar 2009 20:45:38 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again

I test again HTB and HFSC, this time in very simple case.

Regarding HTB - i try without quantum, with different values, without and with 
cburst (big and small), with HZ=1000 and default, hysteresis on and off - it 
is almost same result. 

While i set limit at 57, it can reach 61. HFSC results is perfect.

Here is graph snapshopts.
http://www.nuclearcat.com/netdev/htb-problem.png
You can see points where HTB enabled. Other points if HFSC.

Scripts source is:

HTB http://www.nuclearcat.com/netdev/htb-script.txt
HFSC http://www.nuclearcat.com/netdev/hfsc-script.txt



