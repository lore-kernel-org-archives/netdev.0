From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] switch arcnet over to initcalls
Date: Thu, 22 May 2003 07:57:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522075711.A11759@lst.de>
References: <20030521221638.A7575@lst.de> <20030521.162052.08332261.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030521.162052.08332261.davem@redhat.com>; from davem@redhat.com on Wed, May 21, 2003 at 04:20:52PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 21, 2003 at 04:20:52PM -0700, David S. Miller wrote:
>    From: Christoph Hellwig <hch@lst.de>
>    Date: Wed, 21 May 2003 22:16:38 +0200
> 
>    Link order already equals the old init order.  arcnet init/registration
>    code still is more than fishy, maybe I'll look into that later.
>    
> ISA device init ordering again Christoph, com90xx is an ISA
> driver...

It's not probed from Space.c so it's probed after most isa devices
anyway.  You can't just veto all initcall changes because they are isa
devices  -  if it's the unlikely case that it actually breaks for
someone he can still complain.
