From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipconfig: add nameserver IPs to kernel-parameter ip=
Date: Fri, 21 Sep 2012 13:37:59 -0400 (EDT)
Message-ID: <20120921.133759.1667263015470766968.davem@davemloft.net>
References: <1348176485.3858.92.camel@mars>
	<20120920.173719.1238894522809866676.davem@davemloft.net>
	<1348177730.3858.98.camel@mars>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, kuznet@ms2.inr.ac.ru, j.weitzel@phytec.de,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hjk@hansjkoch.de, daniel@zonque.org
To: chf.fritz@googlemail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1348177730.3858.98.camel@mars>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Fritz <chf.fritz@googlemail.com>
Date: Thu, 20 Sep 2012 23:48:50 +0200

> diff --git a/Documentation/filesystems/nfs/nfsroot.txt b/Documentation/filesystems/nfs/nfsroot.txt
> index ffdd9d8..4ed7875 100644
> --- a/Documentation/filesystems/nfs/nfsroot.txt
> +++ b/Documentation/filesystems/nfs/nfsroot.txt
> @@ -158,6 +158,13 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>
>  
>                  Default: any
>  
> +  <dns0-ip>	IP address of first nameserver.
> +		Value gets exported by /proc/net/pnp which is often linked
> +		on embedded systems by /etc/resolv.conf.
> +
> +  <dns1-ip>	IP address of secound nameserver.
> +		Same as above.
> +
>  
>  nfsrootdebug
>  

This documentation update is not sufficient.

You have to properly show, in the lines above where you made your change,
where the new settings are placed in the "ip=" option.
