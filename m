From: "David S. Miller" <davem@davemloft.net>
Subject: Re: oops with hostap and 2.6.12-rc6-mm1: Kernel BUG at
 "net/ipv4/tcp_output.c":928
Date: Wed, 08 Jun 2005 12:47:28 -0700 (PDT)
Message-ID: <20050608.124728.74558309.davem@davemloft.net>
References: <56hdg93rxb.fsf@depni.sinp.msu.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: belyshev@depni.sinp.msu.ru
In-Reply-To: <56hdg93rxb.fsf@depni.sinp.msu.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Just remove the BUG_ON() assertion in tcp_tso_should_defer(),
it's simply not a correct check when FIN is set in the packet.
