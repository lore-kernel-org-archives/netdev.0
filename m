From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: net-2.6.24 build broken (allyesconfig)
Date: Mon, 27 Aug 2007 15:32:26 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708271522400.16245@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35052 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbXH0Mc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 08:32:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

$ git-reset --hard net-2.6.24-origin
HEAD is now at e2eb35e... [ATM]: Fix build errors after conversion to pr_debug()
$ make allyesconfig
...
$ make bzImage
...
  CC      drivers/net/82596.o
drivers/net/82596.c:1618:1: error: unterminated argument list invoking 
macro "DEB"
drivers/net/82596.c: In function 'set_multicast_list':
drivers/net/82596.c:1564: error: 'DEB' undeclared (first use in this 
function)
drivers/net/82596.c:1564: error: (Each undeclared identifier is reported 
only once
drivers/net/82596.c:1564: error: for each function it appears in.)
drivers/net/82596.c:1564: error: expected ';' at end of input
make[1]: *** [drivers/net/82596.o] Error 1
make: *** [drivers/net/82596.o] Error 2


Hmm, I would guess that "[NET]: Introduce MAC_FMT/MAC_ARG" broken it, 
though didn't verify it.

The fix is left as an exercise of the reader (i.e., the solution wasn't 
too obvious for me :-) )...


--
 i.
