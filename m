From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Introducing open source MSTP daemon
Date: Thu, 22 Sep 2011 17:27:32 +0300
Message-ID: <201109221727.33010.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alex Rozin <alexr@nbase.co.il>,
	Michael Rozhavsky <mike@nbase.co.il>
To: bridge@linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.cyfra.ua ([62.80.160.182]:44867 "EHLO mx3.cyfra.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab1IVO4U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 10:56:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good day!
I am happy to introduce open source MSTP daemon:
http://sourceforge.net/p/mstpd

Of course due to current limitations of the Linux bridge code, namely:
 - no integration with VLAN code
 - no support of different FIDs (independent learning)
 - no support of the per-MSTI port states
this daemon is not very useful for the bare Linux box. It can work only with 
support of specialized driver which talks to the MSTP-aware hardware (most of 
the today ethernet switching parts are MSTP-aware and support FIDs and 
per-MSTI port states).
Nevertheless I hope to find some interest in my work. Maybe it will stimulate 
in some way the integration of the Linux bridge and VLAN code, who knows? 
>From the IEEE point of view they are already merged, see 802.1Q-2005 which 
incorporates previous editions of 802.1q and 802.1d and 802.1w/s.

Once again, all interested are welcome. Please review, criticize, test, 
modify, patch, deploy and do other things :) Any kind of feedback is 
extremely welcome :)

-- 
Vitalii Demianets
