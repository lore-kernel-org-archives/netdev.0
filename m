From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH 2.6.X] SIOCSIFNAME wilcard suppor & name validation
Date: Wed, 14 Jan 2004 16:17:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115001712.GA24056@bougret.hpl.hp.com>
References: <20040112234332.GA1785@bougret.hpl.hp.com> <20040113142204.0b41403b.shemminger@osdl.org> <20040113162112.509edb71.davem@redhat.com> <20040114161324.61b7198f.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040114161324.61b7198f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 14, 2004 at 04:13:24PM -0800, Stephen Hemminger wrote:
> Bug: dev_alloc_name returns the number of the slot used, so comparison needs
> to be < 0.
> 
> diff -Nru a/net/core/dev.c b/net/core/dev.c
> --- a/net/core/dev.c	Wed Jan 14 16:09:02 2004
> +++ b/net/core/dev.c	Wed Jan 14 16:09:02 2004
> @@ -718,7 +718,7 @@
>  
>  	if (strchr(newname, '%')) {
>  		int err = dev_alloc_name(dev, newname);
> -		if (err)
> +		if (err < 0)
>  			return err;
>  		strcpy(newname, dev->name);
>  	}

	Doh ! I feel stupid.

	Jean
