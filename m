From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: Cleaner way to conditionally disallow a CONFIG option as static
Date: Wed, 10 Mar 2004 04:38:23 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403100437040.27654@serv>
References: <Pine.LNX.4.58.0403081659170.1656@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kaos@ocs.com.au, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0403081659170.1656@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 8 Mar 2004, Sridhar Samudrala wrote:

> In 2.6, net/sctp/Kconfig
>
> config IPV6_SCTP__
> 	tristate
> 	default y if IPV6=n
> 	default IPV6 if IPV6
>
> config IP_SCTP
> 	tristate "The SCTP Protocol (EXPERIMENTAL)"
> 	depends on IPV6_SCTP__

This can be written as:

config IP_SCTP
	tristate "The SCTP Protocol (EXPERIMENTAL)"
	depends on IPV6 || IPV6=n

bye, Roman
