From: Pavel Machek <pavel@suse.cz>
Subject: Re: ipw2100: firmware problem
Date: Wed, 8 Jun 2005 18:29:48 +0200
Message-ID: <20050608162947.GB3969@openzaurus.ucw.cz>
References: <20050608142310.GA2339@elf.ucw.cz> <200506081744.20687.vda@ilport.com.ua> <20050608145653.GA8844@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Vlasenko <vda@ilport.com.ua>, Pavel Machek <pavel@ucw.cz>,
        Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jirka Bohac <jbohac@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050608145653.GA8844@dwarf.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> > Do you want to associate to an AP when your kernel boots,
> > _before_ any iwconfig had a chance to configure anything?
> > That's strange.
> > 
> > My position is that wifi drivers must start up in an "OFF" mode.
> > Do not send anything. Do not join APs or start IBSS.
> 
> Agreed.

Me too ;-).

> > Thus, no need to load fw in early boot.
> 
> I don't think this is true. Loading the firmware on the first
> "ifconfig up" is problematic. Often, people want to rename the
> device from ethX/wlanX/... to something stable. This is usually
> based on the adapter's MAC address, which is not visible until
> the firmware is loaded.
> 
> Prism54 does it this way and it really sucks. You need to bring
> the adapter up to load the firmware, then bring it back down,
> rename it, and bring it up again.
> 
> Denis: any plans for this to be fixed?
> 
> I agree that drivers should initialize the adapter in the OFF
> state, but the firmware needs to be loaded earlier than the
> first ifconfig up.
> 
> How about loading the firmware when the first ioctl touches the
> device? This way, it would get loaded just before the MAC address
> is retrieved.

Thats really ugly :-(.

				Pavel
-- 
64 bytes from 195.113.31.123: icmp_seq=28 ttl=51 time=448769.1 ms         
