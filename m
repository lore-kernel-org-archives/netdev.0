From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: page allocation failure
Date: Sat, 16 Oct 2004 21:08:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041016190859.GA21849@electric-eye.fr.zoreil.com>
References: <200410162004.17573.jkillius@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Killius <jkillius@arcor.de>
Content-Disposition: inline
In-Reply-To: <200410162004.17573.jkillius@arcor.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jan Killius <jkillius@arcor.de> :
[...]
> Here is the error:
> swapper: page allocation failure. order:3, mode:0x20
> [<c013131e>]
> [<c0131458>]
> [<c0134337>]

It would be useful to map some of these adresses with the relevant
functions in your System.map.

[...]
> This problem happens while a ftp transfer. The kernel version is
> 2.6.9-rc4 but I'm using the r8169 driver and the netdev snapshot
> from 2.6.9-rc4-mm1.
> 
> ethtool -k:
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on

The r8169 driver is not expected to allocate > 0 order pages until
the day it handles jumbo frames. Scary messages apart, how does the
system behave ?

--
Ueimor
