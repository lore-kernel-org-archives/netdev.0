From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] ieee80211 subsystem
Date: Tue, 8 Feb 2005 13:45:39 -0800
Message-ID: <20050208214539.GA3290@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote :
> 
> 9. Isn't SNAP generic and not part of just wireless, LLC and other places
>    like ATM have the similar stuff, maybe one set of routines and definitions?
> 

	SNAP is totally generic and IMHO should not be tied to the
wireless stuff. I thought that SNAP was defined in 802.2, but RFC 1042
seems to be the place (which is older than 802.11 or ATM).
	First, if you use true IEEE 802.3 (as oppposed to the usual
Ethernet II), the IP frames will use SNAP encapsulation (because the
802.3 frames don't have a type field). I don't think there is many
networks using 802.3 (mostly admin config error), which is why Linux
doesn't seem to support it.
	More importantly, there is a class of wireless drivers that
would only need SNAP but not the rest of the 802.11 framework, because
they use 802.3 frames natively. A good example is the Orinoco driver,
you will find that the driver has SNAP encapsulation and
decapsulation.
	I can't comment on the ATM stuff...
	I think IEEE has not changed their policy with respect to
802.2, so IMHO we can expect more standard from them requiring SNAP in
the future.
	Have fun...

	Jean
