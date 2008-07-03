From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Add missing skb->dev assignment in Frame Relay RX code.
Date: Thu, 03 Jul 2008 23:19:38 +0200
Message-ID: <m3bq1ey8b9.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756604AbYGCVTy@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

How about the Frame-Relay fix, would you like me to repost it?

Alternatively you can get it from (based on 2.6.25):
git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git hdlc-fixes

aka (on *.kernel.org):
/pub/scm/linux/kernel/git/chris/linux-2.6.git	hdlc-fixes

It contains:
$ git-diff --stat v2.6.25
 drivers/net/wan/hdlc_fr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

I'd be glad if it makes it to 2.6.26, it's a) obvious,
b) security-related, c) extra short, d) nobody objected

Thanks in advance.
-- 
Krzysztof Halasa
