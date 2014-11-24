From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Sun, 23 Nov 2014 20:23:21 -0500 (EST)
Message-ID: <20141123.202321.1426718936320546377.davem@davemloft.net>
References: <20141123104623.GA31915@redhat.com>
	<20141123.134323.1154795102254868842.davem@davemloft.net>
	<20141123203032.GA6286@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pagupta@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141123203032.GA6286@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 23 Nov 2014 22:30:32 +0200

> qemu runs in the host, but it's unpriveledged: it gets
> passed tun FDs by a priveledged daemon, and it only
> has the rights to some operations,
> in particular to attach and detach queues.
> 
> The assumption always was that this operation is safe
> and can't make kernel run out of resources.

This creates a rather rediculous situation in my opinion.

Configuring a network device is a privileged operation, the daemon
should be setting this thing up.

In no other context would we have to worry about something like this.
