From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Suspicious code in tun_flow_update()
Date: Sat,  5 Mar 2016 02:04:44 +0300
Message-ID: <1457132684-16118-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	David Gibson <david@gibson.dropbear.id.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Eric Dumazet <edumazet@google.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

If tun_flow_find() successfully finds tun_flow_entry,
tun_flow_update() updates the entry in place.

Is such usage of RCU safe here?

Found by Linux Driver Verification project (linuxtesting.org).
