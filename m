From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH/RFC] disallow vlan devices on top of a logical bridge device
Date: 02 Sep 2003 20:24:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3ptijt5ek.fsf@defiant.pm.waw.pl>
References: <200308301504.03241.bdschuym@pandora.be>
	<20030830203043.0eb1a660.davem@redhat.com>
	<20030902082807.0e18fe76.shemminger@osdl.org>
	<200309021932.37224.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, greearb@candelatech.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309021932.37224.bdschuym@pandora.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer <bdschuym@pandora.be> writes:

> OK. But isn't br0.15 supposed to work like this: all vlan tagged traffic
> with 
> tag different from 15 is discarded, all non-tagged traffic is given to br0.

Actually I think non-VLAN15 traffic shouldn't make it to br0.15 in the
first place, the same with physical ethernet and anything like that.

> The vlan code only sees tagged packets if the 
> packets are destined for the bridge box itself, so bridged traffic is 
> unaffected.

Sure. Do you mean packets received from ethernet interface (br0 port)?
They go to br0, of course. I don't see anything special here.
I understand you don't need VLAN support for trunk bridging. You need
it for locally accessing VLANs (trunk members) only.
-- 
Krzysztof Halasa, B*FH
