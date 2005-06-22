From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 23 Jun 2005 01:23:45 +0200
Message-ID: <20050622232345.GD14251@wotan.suse.de>
References: <20050622.132241.21929037.davem@davemloft.net> <200506222242.j5MMgbxS009935@guinness.s2io.com> <20050622231300.GC14251@wotan.suse.de> <20050622.191956.39166724.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, leonid.grossman@neterion.com, davem@davemloft.net,
        hadi@cyberus.ca, becker@scyld.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20050622.191956.39166724.davem@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2005 at 07:19:56PM -0400, David S. Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Thu, 23 Jun 2005 01:13:00 +0200
> 
> > The computing time must be quite long to be really a win.
> > You need to waste a few hundred cycles at least on a modern fast CPU.
> 
> SKB allocation more than fits this requirement, and that is exactly
> what the RX descriptor replenishment will do.

It shouldn't in theory. Unless they did something bad to the slab
allocator again when I wasn't looking ;-) 

> 
> Even if SKB allocation was only half the necessary number of cycles
> for the prefetch to hit the cpu, it'd still be a win.

If it's too small then it might be left in the noise.

-Andi
