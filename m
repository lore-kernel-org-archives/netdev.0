From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: netlink tester program
Date: Mon, 2 Jun 2003 10:07:54 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030602100754.1e3e1ca8.rddunlap@osdl.org>
References: <20030530090015.7c435c9a.rddunlap@osdl.org>
	<20030530.171111.71099698.davem@redhat.com>
	<32804.4.64.196.31.1054351332.squirrel@www.osdl.org>
	<20030530.234211.102567405.davem@redhat.com>
	<20030531120940.GB11898@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030531120940.GB11898@wotan.suse.de>
List-Id: netdev.vger.kernel.org

On Sat, 31 May 2003 14:09:40 +0200 Andi Kleen <ak@suse.de> wrote:

| > You really need something like rtnl_talk() or rtnl_dump_filter()
| > from libnetlink to do this properly.
| 
| In case it's helpful I wrote manpages for libnetlink some time ago.
| 
| I also have some simple example programs using it. Other examples
| can be found in the zebra or bird source code.

Does this man page live somewhere?  Do some distros ship it?

Where can I find your example programs that use it?

Couple of corrections below....


|        rtnl_listen
|               Receive netlink data after a request and pass it to
|               handler.   handler is a callback that gets the mes-
|               sage source address, the message  itself,  and  the
|               jarg  cookie  as  arguments. It will get called for
+                                            It will be called for
{'get' should usually be avoided when easily done}
|               all received messages.  Only one message bundle  is
|               received.  Unless  there is no message pending this
|               function does not block.
| 
| 
|        rta_addattr32
|               Initialize the rtnetlink attribute rta with a __u32
|               data value.
| 
| 
|        rta_addattr32
+        rta_addattr_l
|               Initialize the rtnetlink attribute rta with a vari-
|               able length data value.


--
~Randy
