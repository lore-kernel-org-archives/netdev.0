From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsec 2.5.70-bk9 and FreeS/WAN 1.99 with algopatches 0.8.1rc2
 (in)compatible encryption methods
Date: Thu, 05 Jun 2003 21:59:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030605.215907.71090944.davem@redhat.com>
References: <35410000.1054818456@klopffest.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pb@bieringer.de
In-Reply-To: <35410000.1054818456@klopffest.muc.aerasec.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Dr. Peter Bieringer" <pb@bieringer.de>
   Date: Thu, 05 Jun 2003 15:07:36 +0200

   because I got no success, I've tried different encryption methods than 
   3DES. And *suddenly* it began to work.
   
Sounds like an out-of-date include/linux/pfkeyv2.h file
used during tool building.
