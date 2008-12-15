From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host
 communication.
Date: Mon, 15 Dec 2008 15:10:44 -0800 (PST)
Message-ID: <20081215.151044.262451532.davem@davemloft.net>
References: <4946C1AA.4080404@codemonkey.ws>
	<20081215.142918.190909950.davem@davemloft.net>
	<4946E1BA.80206@codemonkey.ws>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gleb@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org
To: anthony@codemonkey.ws
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4946E1BA.80206@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anthony Liguori <anthony@codemonkey.ws>
Date: Mon, 15 Dec 2008 17:01:14 -0600

> No, TCP falls under the not simple category because it requires the
> backend to have access to a TCP/IP stack.

I'm at a loss for words if you need TCP in the hypervisor, if that's
what you're implying here.

You only need it in the guest and the host, which you already have,
in the Linux kernel.  Just transport that over virtio or whatever
and be done with it.
