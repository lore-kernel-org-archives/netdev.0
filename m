From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
 communication.
Date: Mon, 15 Dec 2008 11:43:15 -0800 (PST)
Message-ID: <20081215.114315.165733593.davem@davemloft.net>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>
	<20081214.224436.55256593.davem@davemloft.net>
	<4946717F.2090809@codemonkey.ws>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gleb@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: anthony@codemonkey.ws
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4946717F.2090809@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anthony Liguori <anthony@codemonkey.ws>
Date: Mon, 15 Dec 2008 09:02:23 -0600

> There is already an AF_IUCV for s390.

This is a scarecrow and irrelevant to this discussion.

And this is exactly why I asked that any arguments in this thread
avoid talking about virtualization technology and why it's "special."

This proposed patch here is asking to add new infrastructure for
hypervisor facilities that will be _ADDED_ and for which we have
complete control over.

Whereas the S390 folks have to deal with existing infrastructure which
is largely outside of their control.  So if they implement access
mechanisms for that, it's fine.

I would be doing the same thing if I added a protocol socket layer for
accessing the Niagara hypervisor virtualization channels.
