From: Ray Lehtiniemi <rayl@mail.com>
Subject: Re: RE: how to tune a pair of e1000 cards on intel e7501-based system?
Date: Wed, 8 Dec 2004 16:43:10 -0700
Message-ID: <20041208234310.GE8649@mail.com>
References: <C925F8B43D79CC49ACD0601FB68FF50C0293B459@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Scott Feldman <sfeldma@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C0293B459@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hi jesse


On Tue, Dec 07, 2004 at 05:10:26PM -0800, Brandeburg, Jesse wrote:
> 
> I'm not much of an expert, but one easy thing to try is to up your
> receive stack resources, as they were particularly low on 2.4 series
> kernels, leading to udp getting overrun pretty easily with gig nics.  I
> think if you make the value go too high it just ignores it, so if you
> see no change, try 256kB instead.
> 
> cat /proc/sys/net/core/rmem_default
> cat /proc/sys/net/core/rmem_max 
> 
> echo -n 512000 > /proc/sys/net/core/rmem_default
> echo -n 512000 > /proc/sys/net/core/rmem_max

sounds reasonable, i'll try this early next week when i have access
to that test box again.


thanks!

-- 
----------------------------------------------------------------------
     Ray L   <rayl@mail.com>
