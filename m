From: David Miller <davem@davemloft.net>
Subject: Re: Possible NULL dereference caused by -stable commit
 ef81bb40bf15f350fe865f31fa42f1082772a576
Date: Wed, 28 Sep 2011 13:12:42 -0400 (EDT)
Message-ID: <20110928.131242.1368255500458954764.davem@davemloft.net>
References: <4E82FC4E.5010101@redhat.com>
	<1317211749.2941.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gregkh@suse.de, stable@kernel.org,
	mst@redhat.com, akong@redhat.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317211749.2941.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Sep 2011 14:09:09 +0200

> All we need here is not the route but inet_peer, so that inet_getid()
> can be called on it.

It's not exactly that simple, you have to parse all hop-by-hop options
to get the correct "destination" address.
