From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Fw: TcpOutSegs in tcp_mib not RFC1213 compliant?
Date: Wed, 6 Aug 2003 13:20:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030806132032.012d69f4.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mlev@despammed.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This would be more appropriate on the netdev mailing list.
(from lkml)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Date: Tue, 5 Aug 2003 20:01:22 -0400
From: Lev Makhlis <mlev@despammed.com>
To: linux-kernel@vger.kernel.org
Subject: TcpOutSegs in tcp_mib not RFC1213 compliant?


Hi,

>From looking at net/ipv4/tcp_output.c, TcpOutSegs counts all
outgoing packets, including pure retransmits.  This seems
to contradict RFC 1213 (MIB-II):

          tcpOutSegs OBJECT-TYPE
              SYNTAX  Counter
              ACCESS  read-only
              STATUS  mandatory

              DESCRIPTION
                      "The total number of segments sent, including
                      those on current connections but excluding those
                      containing only retransmitted octets."
              ::= { tcp 11 }

Is that intentional or an oversight?

Lev

-
