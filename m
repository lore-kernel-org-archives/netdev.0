From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: 2.4.20-pre11: PCI Wavelan card loses connection
Date: Mon, 13 Jan 2003 09:24:35 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030113172435.GC20409@bougret.hpl.hp.com>
References: <200301130821.h0D8Kis26772@Port.imtp.ilyichevsk.odessa.ua>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200301130821.h0D8Kis26772@Port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 13, 2003 at 10:20:14AM +0200, Denis Vlasenko wrote:
> I bought a PCI wireless card, a DLink-520 (I think, I forgot exactly
> (it's at home), anyway, lspci dump is below).
> 
> We (my father and me) made a fairly long helical aerial.
> We are trying to communicate over ~15 km with a small wireless cell.
> (~10 hosts, one AP).
> 
> We can successfully associate with it, signal is weak as expected.
> But after a short while our eth0 seems to 'fall off the net'
> and while it looks like we can send packets, we see no incoming data
> at all.
> 
> Since I have almost zero wireless experience, I'll be happy if someone
> with said experience can read further and say what bites us.

	Personally, I never managed to get this hardware to work at
all. And Orinoco is known to have problems with PrismII cards. Please
use the HostAP or linux-wlan-ng driver.
	Good luck...

	Jean
