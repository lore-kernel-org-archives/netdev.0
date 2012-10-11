From: Joe Perches <joe@perches.com>
Subject: [RFC net-next] treewide: s/is_<foo>_ether_addr/eth_addr_<foo>
Date: Wed, 10 Oct 2012 17:56:19 -0700
Message-ID: <1349916979.2243.13.camel@joe-AO722>
References: <1349894559.2035.12.camel@joe-AO722>
	 <1349895710.21172.7235.camel@edumazet-glaptop>
	 <1349897005.2035.24.camel@joe-AO722> <1349897923.2035.31.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brian Haley <brian.haley@hp.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36705 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757440Ab2JKA4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 20:56:20 -0400
In-Reply-To: <1349897923.2035.31.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe all the is_<foo>_ether_addr  functions should be renamed
to eth_addr_<foo> for more api/style symmetry.

$ git grep --name-only -E "\bis_\w+_ether_addr" | \
  xargs sed -r -i -e 's/\bis_(\w+)_ether_addr\b/eth_addr_\1/g'
$ git diff --shortstat
 304 files changed, 690 insertions(+), 690 deletions(-)

Maybe add #defines of the old names for a few releases.
