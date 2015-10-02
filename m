From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 0/3] net: dsa: Complete and fix the dsa unbinding
Date: Fri, 2 Oct 2015 12:47:59 +0200
Message-ID: <560E60DF.4000505@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
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

Tested-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Neil Armstrong (3):
  net: dsa: Use devm_ prefixed allocations
  net: dsa: complete dsa_switch_destroy calls
  net: dsa: exit probe if no switch were found

 net/dsa/dsa.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 60 insertions(+), 7 deletions(-)

-- 
1.9.1
