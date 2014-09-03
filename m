From: Paul Bolle <pebolle@tiscali.nl>
Subject: netfilter: NETFILTER_XT_NAT?
Date: Wed, 03 Sep 2014 22:17:24 +0200
Message-ID: <1409775444.5546.47.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <technoboy85@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

Your commit 8993cf8edf42 ("netfilter: move NAT Kconfig switches out of
the iptables scope") just landed in linux-next (ie, in next-20140903).
It claims to add NETFILTER_XT_NAT.

That commit does add two select statements for NETFILTER_XT_NAT, and a
Makefile line checking for NETFILTER_XT_NAT. But it does not add the
actual Kconfig symbol NETFILTER_XT_NAT. This is a bit confusing. Do you
know what may have happened here?


Paul Bolle

