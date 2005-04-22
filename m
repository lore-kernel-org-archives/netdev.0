From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Thu, 21 Apr 2005 20:32:19 -0400
Message-ID: <1114129939.10572.29.camel@localhost.localdomain>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
	 <4252EB9D.9070305@trash.net>	<20050407120417.4297cd14@dxpl.pdx.osdl.net>
	 <42628300.9010007@trash.net>
	 <20050419110639.47767113@localhost.localdomain>
	 <42666098.5060409@trash.net>
	 <20050421132020.41858bc4@localhost.localdomain>
	 <426832E1.7020003@trash.net>
	 <20050422092221.4950e23c@localhost.localdomain>
	 <426839B4.2090502@trash.net>
	 <1114128336.10572.12.camel@localhost.localdomain>
	 <426840E3.8000203@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <426840E3.8000203@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-22-04 at 02:10 +0200, Patrick McHardy wrote:
> jamal wrote:
> > Duplication of packets would be trivial to do with mirred mirror option
> > attached to the qdisc.
> 
> The problem with duplication and queueing to the device is that
> the packet needs to take the same classification-path as the
> original packet to end up in the same leaf-queue. This can only
> be guaranteed by restricting which classifiers can be used.

What i described happens before the queueing. So packets should end up
in the same leaf queue because the same classifier rule is used to
select the dup action. I should actually try to make sure it works;

cheers,
jamal
