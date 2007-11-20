From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 0/4] Convert IP4 address class macros to inline
	functions
Date: Mon, 19 Nov 2007 22:40:12 -0800
Message-ID: <1195540812.4675.89.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2489 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbXKTGkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:40:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions ipv4_is_<type>(__be32 addr)

Adds some type safety and arguably some readability

No change in compiled image size

Signed-off-by: Joe Perches <joe@perches.com>


