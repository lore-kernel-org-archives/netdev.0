From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] [NET] Various sock struct reorderings
Date: Wed, 9 Mar 2005 20:45:21 +0100
Message-ID: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following patchset reorders various sock structures to avoid padding and
shrinks various oversized fields to save space. This will probably break
various external modules so maybe we should defer this.

Savings on my x86 box:
  rawv6_sock:    696 ->  668
  udpv6_sock:    668 ->  640
  tcpv6_sock:   1232 -> 1192
  unix_sock:     464 ->  452
  raw_sock:      548 ->  524
  udp_sock:      556 ->  532
  tcp_sock:     1120 -> 1084
  sock:          388 ->  376

I didn't benchmark any cachline effects though.
