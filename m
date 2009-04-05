From: Jesper Krogh <jesper@krogh.cc>
Subject: e1000: eth2: e1000_clean_tx_irq: Detected Tx Unit Hang
Date: Sun, 05 Apr 2009 10:11:42 +0200
Message-ID: <49D867BE.1010700@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:55369 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757676AbZDEILp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 04:11:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a 2.6.27.20 system in production, the e1000 drivers seem pretty 
"noisy" allthough everything appears to work excellent.

dmesg here: http://krogh.cc/~jesper/dmesg-ko-2.6.27.20.txt

[476197.380486] e1000: eth3: e1000_clean_tx_irq: Detected Tx Unit Hang
[476197.380488]   Tx Queue             <0>
[476197.380489]   TDH                  <c>
[476197.380490]   TDT                  <63>
[476197.380490]   next_to_use          <63>
[476197.380491]   next_to_clean        <b>
[476197.380491] buffer_info[next_to_clean]
[476197.380492]   time_stamp           <10717579a>
[476197.380492]   next_to_watch        <f>
[476197.380493]   jiffies              <107175a3e>
[476197.380494]   next_to_watch.status <0>

The system has been up for 14 days but the dmesg-buffer has allready 
overflown with these.

Configuratoin is a 4 x 1GbitE bond all with Intel NICs

06:01.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
Controller (Copper) (rev 03)
06:01.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
Controller (Copper) (rev 03)
06:02.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
Controller (Copper) (rev 03)
06:02.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
Controller (Copper) (rev 03)



-- 
Jesper
