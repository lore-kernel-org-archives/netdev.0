From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [PATCH 0/2] Try that again: Small tty fixes touching tty/net drivers
Date: Fri, 05 Dec 2008 17:10:31 +0000
Message-ID: <20081205170846.3528.67581.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:46234 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751846AbYLERKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 12:10:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---

Alan Cox (2):
      tty: driverdata and discdata are void *
      tty: Flags should be accessed via the foo_bit interfaces


 drivers/net/irda/irtty-sir.c |    7 +++----
 drivers/net/slip.c           |   11 +++++------
 drivers/net/wan/x25_asy.c    |   18 +++++++++---------
 drivers/net/wireless/strip.c |   18 ++++++++----------
 4 files changed, 25 insertions(+), 29 deletions(-)

-- 
	"What is needed now is not smart weapons, it is smart politicians"
			- Tony Benn

