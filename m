From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Wed, 11 Jun 2003 20:20:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.202003.74721468.davem@redhat.com>
References: <3EE5F85E.9080006@tml.hut.fi>
	<20030610.095135.28806569.davem@redhat.com>
	<3EE6ECD3.6050103@tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: lpetande@tml.hut.fi
In-Reply-To: <3EE6ECD3.6050103@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Henrik Petander <lpetande@tml.hut.fi>
   Date: Wed, 11 Jun 2003 11:48:19 +0300
   
   Does this make sense to you?

No it doesn't. When you startup zebra, it may flush the entire
routing table.

You must make zebra aware of any static or dynamic routes you care
about.  It manages entire routing table and that is the end of
the story.
