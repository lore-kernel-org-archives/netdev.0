From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: PATCH: sundance #2
Date: Thu, 19 Sep 2002 14:13:56 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3D8A13E4.6010300@mandrakesoft.com>
References: <Pine.LNX.4.44.0209191316300.29420-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jason Lunz <lunz@falooley.org>,
	Richard Gooch <rgooch@ras.ucalgary.ca>,
	"Patrick R. McManus" <mcmanus@ducksong.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	edward_peng@dlink.com.tw
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Donald Becker <becker@scyld.com>
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> +/* Set iff a MII transceiver on any interface requires mdio preamble.
> +   This only set with older tranceivers, so the extra
> +   code size of a per-interface flag is not worthwhile. */
> +static int mii_preamble_required = 0;
> 
> You can get rid of this as a module option, and make it a per-interface
> setting. 
> The transceiver on the Kendin chip requires this (rather old-fashioned)
> access method, while none of the previous Sundance-based boards with
> external transceivers did.
> 
> I added it as a module parameter as a back-up over-ride, but I'm certain
> that the automatic detection works.

Good enough for me...


>>				Theory of Operation
> 
> 
> Whoever changed the transmit path should update the TOO.  

noted



> -	{"Sundance Technology Alta", {0x020113F0, 0xffffffff,},
> -	 PCI_IOTYPE, 128, CanHaveMII},
> +	{"D-Link DFE-550TX FAST Ethernet Adapter"},
> +	{"D-Link DFE-550FX 100Mbps Fiber-optics Adapter"},
> 
> Yeah, you should probably throw away the rest of the changes.
> You are probably going to want to keep the drv_flags field.  I know
> that all of the current chips have the same flag (CanHaveMII), but...


That's probably a style area that you and I will disagree on... :)

	Jeff
