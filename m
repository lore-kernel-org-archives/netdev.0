From: "David S. Miller" <davem@redhat.com>
Subject: Re: netlink tester program
Date: Fri, 30 May 2003 23:42:11 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030530.234211.102567405.davem@redhat.com>
References: <20030530090015.7c435c9a.rddunlap@osdl.org>
	<20030530.171111.71099698.davem@redhat.com>
	<32804.4.64.196.31.1054351332.squirrel@www.osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rddunlap@osdl.org
In-Reply-To: <32804.4.64.196.31.1054351332.squirrel@www.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Fri, 30 May 2003 20:22:12 -0700 (PDT)
   
   Oh well, it's at this URL, bugs and all.
   
   http://www.xenotime.net/linux/ipv6/rtnl_test.c
   
I know you don't want to use libnetlink from iproute2, but I want to
stress that it takes care of all of the minutae of netlink socket
usage that you have to duplicate in your little test program and this
duplication leads to bugs.

Firstly, you needs to be fixed to call recvmsg() multiple times,
you'll get one entry for each recvmsg call in the table you are
querying.

You really need something like rtnl_talk() or rtnl_dump_filter()
from libnetlink to do this properly.
