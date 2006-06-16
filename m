From: Juergen Kreileder <jk@blackdown.de>
Subject: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 18:50:12 +0200
Message-ID: <87psh9kptn.fsf@blackdown.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.blackdown.de ([213.239.206.42]:31131 "EHLO
	smtp.blackdown.de") by vger.kernel.org with ESMTP id S1751491AbWFPQuT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 12:50:19 -0400
To: linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm seeing frequent network timeouts on my PowerMac G5 Quad with
2.6.17-rc6.  The timeouts are easily reproducible with moderate
network traffic, e.g. by using bittorrent.

,----
| NETDEV WATCHDOG: lan0: transmit timed out
| tg3: lan0: transmit timed out, resetting
| tg3: tg3_stop_block timed out, ofs=2c00 enable_bit=2
| tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
| tg3: lan0: Link is down.
| [...]
| tg3: lan0: Link is up at 1000 Mbps, full duplex.
| tg3: lan0: Flow control is on for TX and on for RX.
`----


        Juergen

-- 
Juergen Kreileder, Blackdown Java-Linux Team
http://blog.blackdown.de/
