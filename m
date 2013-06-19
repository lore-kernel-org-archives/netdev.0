From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-06-19
Date: Wed, 19 Jun 2013 09:02:48 +0200
Message-ID: <1371625369-26368-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here are there fixes for the v3.10 release cycle:

Michael Olbrich reported an Oops (free_netdev() on registered netdev) with the
8devices USB CAN converter on xhci USB host controllers. I've created a patch
to fix the error path of the driver.

regards,
Marc

---

The following changes since commit 33be081a812098567898bbe23b581460331a986f:

  ipv6: ndisc: fix ndisc_send_redirect writing to the wrong skb (2013-06-17 22:59:12 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.10

for you to fetch changes up to 4afe2156eb639e563d6ef0c2706b66ea400348b2:

  can: usb_8dev: unregister netdev before free()ing (2013-06-19 08:56:10 +0200)

----------------------------------------------------------------
Marc Kleine-Budde (1):
      can: usb_8dev: unregister netdev before free()ing

 drivers/net/can/usb/usb_8dev.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)


