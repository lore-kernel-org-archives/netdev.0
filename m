From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bridge: netfilter: spanning tree: Add
 masked_ether_addr_equal and neatening
Date: Thu, 23 Jun 2016 12:00:00 -0700
Message-ID: <1466708400.1847.15.camel@perches.com>
References: <f39576f17e9f5dee35258917917f2d740e820a77.1466024030.git.joe@perches.com>
	 <20160623173659.GA3474@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0006.hostedemail.com ([216.40.44.6]:60299 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751713AbcFWTGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 15:06:09 -0400
In-Reply-To: <20160623173659.GA3474@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-06-23 at 19:36 +0200, Pablo Neira Ayuso wrote:
> On Wed, Jun 15, 2016 at 01:58:45PM -0700, Joe Perches wrote:
> >=20
> > There is code duplication of a masked ethernet address comparison h=
ere
> > so make it a separate function instead.
> >=20
> > Miscellanea:
> >=20
> > o Neaten alignment of FWINV macro uses to make it clearer for the r=
eader
> Applied, thanks.
>=20
> >=20
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >=20
> > This masked_ether_addr_equal function could go into etherdevice.h,
> > but I don't see another use like it in kernel code.=A0=A0Is there o=
ne?
> This is specific of iptables, not even nftables would use this. So I
> would keep this in the iptables tree.

Did you see the other patch that adds a generic
ether_addr_equal_masked() and uses it in a few
more files?
