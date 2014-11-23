From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Sun, 23 Nov 2014 13:43:23 -0500 (EST)
Message-ID: <20141123.134323.1154795102254868842.davem@davemloft.net>
References: <20141119.151628.768548269128919029.davem@davemloft.net>
	<20141119204427.GB30994@redhat.com>
	<20141123104623.GA31915@redhat.com>
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
In-Reply-To: <20141123104623.GA31915@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 23 Nov 2014 12:46:23 +0200

> At the moment attaching/detaching queues is an unpriveledged operation.
> 
> Shouldn't we worry that an application can cause large
> allocations, and provide a way to limit these?
> 
> David, could you comment on this please?

I don't want arbitrary limits imposed.

Where does this "application" run?  If it's in the host, then who
cares?  If they suck up all of their available memory with queue
resources, it's their problem.
