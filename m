From: Joshua Stewart <joshua.stewart@comcast.net>
Subject: Pushing a stray sk_buff to the NIC
Date: Thu, 09 Jan 2003 20:10:53 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1042161058.6107.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux network development <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

I'm trying to take "hand-built" sk_buffs with little more than some data
and a dev member and push them to the NIC for transmission.  I would
like to simply give them to dev_queue_xmit.  Does anybody know what
state I should have them in before handing them to dev_queue_xmit? 
Should skb->data point to the start of a MAC header or an IP header?

Also, given an IP address in skb->nh.iph->daddr, what's the easiest way
to get the appropriate MAC address?

J
