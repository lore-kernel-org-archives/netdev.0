From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: linux-wireless mailing list
Date: Thu, 4 Mar 2004 09:34:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304173410.GA4197@bougret.hpl.hp.com>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <40469DA1.9090502@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40469DA1.9090502@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 03, 2004 at 10:08:17PM -0500, Jeff Garzik wrote:
> 
> The wireless extensions are utility -- they work, but are not beautiful. 
>  I am presently writing the driver for the RealTek wireless card, and 
> in the process creating a small wireless driver API.  The ideal is to 
> avoid ioctls, and instead to present extensible, type-safe interfaces. 
> This is what I would like wireless extensions to morph into.

	Just for the record. The new driver API of WE is no longer
tied to ioctls. The goal was to change the external API to RtNetlink,
but I got distracted. But, you could imagine plugging the driver API
to a file system (there is so many of them, take your pick).
	I believe that migrating the external API to RtNetlink would
address 99% of your concerns, isn't it ? If this is the case, then we
could work to make this happen.
	I've always say that the mechanism of the API does not matter,
what matter is the standardisation of the parameters and data types.

> Absolutely.  David Miller, Arnaldo Carvalho de Melo, and myself all seem 
> to feel that a net/802_11 directory and associated code would be useful. 
>  There is definitely an area for code commonality across drivers.

	1) Please don't start from scratch.
	2) Please keep the 802.2 and 802.11 part separated. Actually,
getting 802.2 alone would be so useful.

> Best regards and welcome,
> 
> 	Jeff

	Jean
