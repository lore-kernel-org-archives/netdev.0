From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: Mail delivery failed: returning message to sender
Date: Wed, 21 May 2003 10:07:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521100725.A17709@flint.arm.linux.org.uk>
References: <20030521012148.P10585@flint.arm.linux.org.uk> <20030520.175553.35669773.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030520.175553.35669773.davem@redhat.com>; from davem@redhat.com on Tue, May 20, 2003 at 05:55:53PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 20, 2003 at 05:55:53PM -0700, David S. Miller wrote:
> Russel, please retest using this patch.  This piece of
> code needs to be audited further.

This appears to fix the problem, thanks.

> --- net/ipv4/route.c.~1~	Tue May 20 17:53:55 2003
> +++ net/ipv4/route.c	Tue May 20 17:54:12 2003
> @@ -964,6 +964,7 @@
>  				rt->u.dst.neighbour	= NULL;
>  				rt->u.dst.hh		= NULL;
>  				rt->u.dst.obsolete	= 0;
> +				rt->u.dst.path		= &rt->u.dst;
>  
>  				rt->rt_flags		|= RTCF_REDIRECTED;
>  

-- 
Russell King (rmk@arm.linux.org.uk)                The developer of ARM Linux
             http://www.arm.linux.org.uk/personal/aboutme.html
