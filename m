From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 0/3] ser_gigaset fixes
Date: Tue,  8 Dec 2015 12:00:33 +0100 (CET)
Message-ID: <cover.1449570042.git.tilman@imap.cc>
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	<syzkaller@googlegroups.com>, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	<gigaset307x-common@lists.sourceforge.net>,
	<linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

this series is the result of our discussion on the "freeing an
active object" bug. I split my proposed patch into two patches
for the separate topics of moving the ser_cardstate kfree() and
dropping the useless kfree()s, and also included an unrelated
patch (1/3) that had fallen through the cracks in my last series.

Patch 2/3 should go into stable releases all the way back to 2.6.32.
It applies cleanly to release 3.*/4.* with at most offset 1.
For release 2.6.32 there is a trivial merge conflict with a removed
comment line.

Thanks,
Tilman

Tilman Schmidt (3):
  ser_gigaset: fix up NULL checks
  ser_gigaset: fix deallocation of platform device structure
  ser_gigaset: remove unnecessary kfree() calls from release method

 drivers/isdn/gigaset/ser-gigaset.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

-- 
1.9.2.459.g68773ac
