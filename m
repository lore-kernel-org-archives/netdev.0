From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Sun, 23 Nov 2014 22:30:32 +0200
Message-ID: <20141123203032.GA6286@redhat.com>
References: <20141119.151628.768548269128919029.davem@davemloft.net>
 <20141119204427.GB30994@redhat.com>
 <20141123104623.GA31915@redhat.com>
 <20141123.134323.1154795102254868842.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pagupta@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, wuzhy@linux.vnet.ibm.com, xemul@parallels.com,
	therbert@google.com, bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141123.134323.1154795102254868842.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 23, 2014 at 01:43:23PM -0500, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 23 Nov 2014 12:46:23 +0200
> 
> > At the moment attaching/detaching queues is an unpriveledged operation.
> > 
> > Shouldn't we worry that an application can cause large
> > allocations, and provide a way to limit these?
> > 
> > David, could you comment on this please?
> 
> I don't want arbitrary limits imposed.
> 
> Where does this "application" run?  If it's in the host, then who
> cares?  If they suck up all of their available memory with queue
> resources, it's their problem.

qemu runs in the host, but it's unpriveledged: it gets
passed tun FDs by a priveledged daemon, and it only
has the rights to some operations,
in particular to attach and detach queues.

The assumption always was that this operation is safe
and can't make kernel run out of resources.


-- 
MST
