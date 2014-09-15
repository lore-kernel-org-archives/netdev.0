From: Meelis Roos <mroos@linux.ee>
Subject: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Tue, 16 Sep 2014 02:14:54 +0300 (EEST)
Message-ID: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	netdev@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Somewhere between 3.17.0-rc3 and 3.17.0-rc5 I started seeing dropped ssh 
connections to a couple of test servers with dual AthlonMP (32-bit) and 
3C90x family of NICs (3Com Corporation 3c980-C 10/100baseTX NIC 
[Python-T] (rev 78) in one server and 3Com Corporation 3c905C-TX/TX-M 
[Tornado] (rev 78) in the other server). Bisect leads to the following 
commit:

98ea232cf63961fad734cc8c5e07e8915ec73073 is the first bad commit
commit 98ea232cf63961fad734cc8c5e07e8915ec73073
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Thu Sep 4 06:13:38 2014 -0400

    3c59x: avoid panic in boomerang_start_xmit when finding page address:
    ...

-- 
Meelis Roos (mroos@linux.ee)
