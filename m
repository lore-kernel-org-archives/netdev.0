From: jamal <hadi@cyberus.ca>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: 14 Feb 2004 08:06:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076763997.1059.13.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
	 <20040211200549.736fa8b3.davem@redhat.com>
	 <1076561489.1032.65.camel@jzny.localdomain>
	 <1076561998.1035.72.camel@jzny.localdomain>
	 <1076562282.1033.76.camel@jzny.localdomain>
	 <20040211211536.23e97997.davem@redhat.com>
	 <1076563502.1031.85.camel@jzny.localdomain>
	 <1076564638.1033.91.camel@jzny.localdomain>
	 <20040211215142.7f817513.davem@redhat.com>
	 <1076566176.1033.94.camel@jzny.localdomain>
	 <20040211222259.776ad818.davem@redhat.com> <402D54D6.5070708@trash.net>
	 <20040213213606.5a13cc76.davem@redhat.com>
	 <1076762757.1060.4.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, qnex@atlantis.knm.org.pl,
        netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1076762757.1060.4.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On second thought:
Dawid noticed that SFQ and RED appear immune to this problem
(i think any non classful qdisc would exhibit same behavior).
Maybe we should allow for this behavior for consistency.
The suggestion that Alexey made  of setting limit of 1 to default 
child fifo when tx_queue_len is 0 is the better appraoch instead of
touching these devices.

cheers,
jamal

jamal wrote:
> On Sat, 2004-02-14 at 00:36, David S. Miller wrote:
> 
> > However, I do agree with you, and we should not promote this kind of crap.
> > I'm going to revert the changeset that set tx_queue_len to 1 in the tunnels.
> 
> I concur. But you gotta admit if that was a bug, it was the fastest
> fixed bug of the week ;->
> 
> cheers,
> jamal
> 
> 
> 
> 
> 
