From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/1] UDEV - Add 'udevlom' command line param to start_udev
Date: Mon, 15 Nov 2010 11:32:28 -0800
Message-ID: <4CE18ACC.3020508@hp.com>
References: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>	<20101103180500.GA7441@kroah.com>	<20101105025848.GA14021@pws490.domsch.com>	<20101115164714.GB7030@auslistsprd01.us.dell.com> <1289841399.2586.18.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@Dell.com>, Greg KH <greg@kroah.com>,
	"K, Narendra" <Narendra_K@Dell.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1289841399.2586.18.camel@bwh-desktop>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>I'm getting a lot of pushback from Dell customers on our
>>linux-poweredge mailing list (thread starts [1]) that the choice of
>>name "lomX" is poor, due to HP's extensive use of LOM meaning Lights
>>Out Management, rather than my intended meaning of "LAN on
>>Motherboard".  Gotta hate TLA collisions.

I think Sun (sorry, Oracle) push LOM for Lights-Out Management quite a lot - 
calling their service processor an iLOM IIRC.

>>So, I'm open to new ideas for naming these.  At LPC, Ted noted that
>>2- and 3-letter names are expected.  "nic[1234]" or "en[1234]" ?
> 
> [...]
> 
> I would suggest avoiding "nic" since some people use "NIC" to mean
> specifically an add-in card rather than LOM.  In addition there is some
> ambiguity with multi-port cards/controllers of whether NIC means a
> controller or a port.
> 
> Other options for the prefix:
> - "lan".  Maybe too generic.

yes and no - that is the prefix for "ethernet" network interface names in HP-UX, 
going back decades.  so, there is precedent for that, and given the way HP-UX 
device name persistence works, 99 times out of ten, the "built-in" or "core" LAN 
interfaces ended-up being enumerated starting from zero - lan0, lan1, etc. 
(There are exceptions relating to certain modles of systems and a full 
re-install of the OS with add-on cards present but that is a story for another 
thread).

> - "mbe" = MotherBoard Ethernet. Looks a bit like "GbE" as some OEMs put
> on the port labels.

Collides with Multi-Bit Error.

> - "eom" = Ethernet On Motherboard

Collides with End of Message.

If there is indeed *no* way to get then named eth[1-N], and "lan" doesn't 
resonate well-enough, then my contribution to the bikeshed would be "cor" simply 
because I don't know the TLA with which that collides :)

Are folks sufficently confident that using anything other than "eth" won't cause 
some unpleasant "our app always ass-u-me-d interfaces started with 'eth'" 
situations?

rick jones
