From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: Fw: issues with SO_PRIORITY and IP_TOS
Date: 05 Nov 2003 09:54:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068044059.1022.0.camel@jzny.localdomain>
References: <200311041233.PAA15518@yakov.inr.ac.ru>
	 <3FA7DBB5.1090500@nortelnetworks.com>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey <kuznet@ms2.inr.ac.ru>, "David S. Miller" <davem@redhat.com>,
        jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3FA7DBB5.1090500@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-11-04 at 12:02, Chris Friesen wrote:

> > I do not even think that IP_DSCP makes sense in diffserv environment.
> > Packets are marked according to DS rules, not according to desire
> > of particular user.
> 
> If root wants to send out a packet with particular DSCP settings, 
> doesn't it make sense to make that option available?  It's a field in 
> the IP packet header, we should be able to set it with an IP option.
> 

Just to give you some history:
This topic has been discussed to death in the past. Look at the diffserv
mailing lists.
Common practise is that the network manager controls the DSCP. They
_never_ trust the user. Of course this gives a lot of power to
network managers and router vendors such as nortel. But these guys
own the network. Qos is a way for them to make more money from different
services. The only OS vendor that made noise on this was MS. And they
lost too. I think thye now have a diffserv API which is not different
from what we have on tc.

BTW, i would worry about the vlan 802.1p QoS settings. While they may
appear to give you QoS within the box, once those bits start crossing
the network with switches that do 802.1q/p you may find that the result
is the opposite. 

cheers,
jamal
