From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: netlink tester program
Date: Mon, 2 Jun 2003 14:04:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030602140452.039248de.rddunlap@osdl.org>
References: <20030530090015.7c435c9a.rddunlap@osdl.org>
	<20030530.171111.71099698.davem@redhat.com>
	<32804.4.64.196.31.1054351332.squirrel@www.osdl.org>
	<20030530.234211.102567405.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030530.234211.102567405.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 May 2003 23:42:11 -0700 (PDT) "David S. Miller" <davem@redhat.com> wrote:

|    From: "Randy.Dunlap" <rddunlap@osdl.org>
|    Date: Fri, 30 May 2003 20:22:12 -0700 (PDT)
|    
|    Oh well, it's at this URL, bugs and all.
|    
|    http://www.xenotime.net/linux/ipv6/rtnl_test.c
|    
| I know you don't want to use libnetlink from iproute2, but I want to
| stress that it takes care of all of the minutae of netlink socket
| usage that you have to duplicate in your little test program and this
| duplication leads to bugs.
| 
| Firstly, you needs to be fixed to call recvmsg() multiple times,
| you'll get one entry for each recvmsg call in the table you are
| querying.

Yes, I noticed that I was getting only 1 msg there.

| You really need something like rtnl_talk() or rtnl_dump_filter()
| from libnetlink to do this properly.

Does anyone have documentation (or semantics) for rtnl_talk()?
or just some blurb about it?
Andi's libnetlink man page missed it somehow.

Thanks,
--
~Randy
