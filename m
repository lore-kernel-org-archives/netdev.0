From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net v2 0/4] Few mvneta fixes
Date: Sat, 12 Mar 2016 18:44:16 +0100
Message-ID: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Dimitri Epshtein <dima@marvell.com>,
	Ofer Heifetz <oferh@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:54411 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752189AbcCLRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 12:44:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

In this second version I split the last patch in two parts as
requested.

For the record the initial cover letter was:
"here is a patch set of few fixes. Without the first one, a kernel
configured with debug features ended to hang when the driver is built
as a module and is removed. This is quite is annoying for debugging!

The second patch fix a forgotten flag at the initial submission of the
driver.

The third patch is only really a cosmetic one so I have no problem to
not apply it for 4.5 and wait for 4.6.

I really would like to see the first one applied for 4.5 and for the
second I let you judge if it something needed for now or that should
wait the next release."

Thanks,

Gregory


Dmitri Epshtein (3):
  net: mvneta: enable change MAC address when interface is up
  net: mvneta: fix error messages in mvneta_port_down function
  net: mvneta: replace magic numbers by existing macros

Gregory CLEMENT (1):
  net: mvneta: Fix spinlock usage

 drivers/net/ethernet/marvell/mvneta.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

-- 
2.5.0
