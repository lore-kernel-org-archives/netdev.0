From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/3 v4] macvtap driver
Date: Sat, 30 Jan 2010 23:22:15 +0100
Message-ID: <201001302322.15237.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:65204 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab0A3W0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 17:26:17 -0500
In-Reply-To: <201001271104.20607.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the fourth version of the macvtap driver,
based on the comments I got for the last version
I got a few days ago. Very few changes:

* release netdev in chardev open function so
  we can destroy it properly.
* Implement TUNSETSNDBUF
* fix sleeping call in rcu_read_lock
* Fix comment in namespace isolation patch
* Fix small context difference to make it apply
  to net-next

I can't really test here while travelling, so please
give it a go if you're interested in this driver.

	Arnd

