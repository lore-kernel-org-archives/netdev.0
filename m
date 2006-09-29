From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 0/6]: powerpc/cell spidernet ethernet patches
Date: Fri, 29 Sep 2006 18:05:52 -0500
Message-ID: <20060929230552.GG6433@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James K Lewis <jklewis@us.ibm.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:43950 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S932272AbWI2XFy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 19:05:54 -0400
To: jeff@garzik.org, akpm@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please apply and forward upstream as appropriate.

Although these patches have not been baking in 
any -mm tree, they have been tested and are 
generally available as a part of the Cell SDK 2.0
overseen by Arnd Bergmann. (Arnd, if you want
to lend a voice of authority here, or to correct 
me, please do so...)

The following sequence of six patches implement a 
series of changes to the transmit side of the 
spidernet ethernet device driver, significantly 
improving performance for large packets.

This series of patches is almost identical to 
those previously mailed on 18-20 August, with one
critical change: NAPI polling is used instead of 
homegrown polling.

Although these patches improve things, I am not
satisfied with how this driver behaves, and so 
plan to do additional work next week. 

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Signed-off-by: James K Lewis <jklewis@us.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>

--linas
