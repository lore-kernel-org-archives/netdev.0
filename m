From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism / Hostap Bridge Problems...
Date: Fri, 10 Dec 2004 20:16:31 -0800
Message-ID: <20041211041631.GB7015@jm.kir.nu>
References: <41B9B6E9.7010600@novolab.de> <41B9C4E0.40407@novolab.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Brande <brande@novolab.de>
Content-Disposition: inline
In-Reply-To: <41B9C4E0.40407@novolab.de>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 10, 2004 at 04:46:40PM +0100, Brande wrote:

> I have a meshcube (www.meshcube.org) with two prim 2.5 mini-pci WLAN 
> cards...
> wlan0 should connect as client (managed mode) to a normal access point 
> which is connected to the internet.
> wlan1 should work as accesspoint (master mode).
> I would like to bridge between wlan0 and wlan1 so that I can connect 

IEEE 802.11 protocol does not support this kind of configuration. The
card in client mode can only send packet with its own layer 2 MAC
address whereas bridge functionality would require that the other MAC
addresses can also be used as source address. If it is enough to handle
only some IP protocols, Proxy ARP or IP routing could be used to setup
this kind of network. Another option would be to use WDS link between
these APs (assuming the other AP supports WDS) and bridge packet through
it.

-- 
Jouni Malinen                                            PGP id EFC895FA
