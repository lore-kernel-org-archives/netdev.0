From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 0/3] net: dsa: Complete and fix the dsa unbinding
Date: Wed, 30 Sep 2015 10:21:04 +0200
Message-ID: <560B9B70.6030202@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to cleanly unbind the dsa core, either as a module removal,
or a platform device unbind, switch the allocation the their devm_
counterparts and complete the destroy functions.

The last patch is an experimental way to exit the probe when no
switch is found in the discover process.

The patches are based on the current net-next.

Neil Armstrong (3):
  net: dsa: Use devm_ prefixed allocations
  net: dsa: complete dsa_switch_destroy calls
  net: dsa: exit probe if no switch were found

 net/dsa/dsa.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 60 insertions(+), 7 deletions(-)

-- 
1.9.1
