From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6]: Fix device leaks in mirred action
Date: 04 Nov 2004 10:23:53 -0500
Message-ID: <1099581832.1080.15.camel@jzny.localdomain>
References: <4189CC6A.9040007@trash.net>
	 <1099576439.1038.147.camel@jzny.localdomain>  <418A439F.2010401@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418A439F.2010401@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-11-04 at 09:58, Patrick McHardy wrote:
> jamal wrote:
> 
> >>It also leaks a reference when a mirred action
> >>is replaced.
> >
> >How? Is this patch supposed to fix that?
> >  
> >
> +                       if (ovr)
> +                               dev_put(p->dev);
>                         p->dev = dev;
> 
> By dropping the reference before replacing it.
> 

Ok, makes sense. Thanks Patrick.
Dave please apply the patch in its entirety.

cheers,
jamal
