From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-net 0/4] Increase the limit of tuntap queues
Date: Sun, 23 Nov 2014 12:46:23 +0200
Message-ID: <20141123104623.GA31915@redhat.com>
References: <1416327778-17716-1-git-send-email-pagupta@redhat.com>
 <20141119.151628.768548269128919029.davem@davemloft.net>
 <20141119204427.GB30994@redhat.com>
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
In-Reply-To: <20141119204427.GB30994@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2014 at 10:44:27PM +0200, Michael S. Tsirkin wrote:
> On Wed, Nov 19, 2014 at 03:16:28PM -0500, David Miller wrote:
> > From: Pankaj Gupta <pagupta@redhat.com>
> > Date: Tue, 18 Nov 2014 21:52:54 +0530
> > 
> > > - Accept maximum number of queues as sysctl param so that any user space 
> > >   application like libvirt can use this value to limit number of queues. Also
> > >   Administrators can specify maximum number of queues by updating this sysctl
> > >   entry.
> > 
> > This is the only part I don't like.
> > 
> > Just let whoever has privileges to configure the tun device shoot
> > themselves in the foot if they want to by configuring "too many"
> > queues.
> > 
> > If the virtual entity runs itself out of resources by doing something
> > stupid, it's purely their problem.
> 
> Well it will run host out of kernel, no?


To clarify:

At the moment attaching/detaching queues is an unpriveledged operation.

Shouldn't we worry that an application can cause large
allocations, and provide a way to limit these?

David, could you comment on this please?

> -- 
> MST
