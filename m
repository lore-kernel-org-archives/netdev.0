From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: [PATCH] IPV6: strategy hander for net.ipv6.conf.*.forwarding (is Re: problem setting net.ipvX.conf.all.forwarding via sysctl() system call)
Date: Fri, 8 Aug 2003 11:37:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808093704.GA18131@wsx.ksp.sk>
References: <20030803154427.GA12926@wsx.ksp.sk> <20030808.175030.19527061.yoshfuji@linux-ipv6.org>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030808.175030.19527061.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 08, 2003 at 05:50:30PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:

> +	*valp = new;
> +	if (valp != &ipv6_devconf.forwarding &&
> +	    valp != &ipv6_devconf_dflt.forwarding) {
> +		struct inet6_dev *idev = (struct inet6_dev *)table->extra1;
> +		if (!idev)
> +			return -ENODEV;
> +		addrconf_forward_change(idev);
> +	}
> +	return 0;
> +}

Shouldn't we set ipv6_devconf_dflt.forwarding and call
addr_forward_change(NULL) in case that valp==&ipv6_devconf.forwarding?


-- 
Jan Oravec                           XS26 coordinator
6COM s.r.o.                          'Access to IPv6'
http://www.6com.sk                   http://www.xs26.net
