From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Fri, 22 Apr 2005 02:10:11 +0200
Message-ID: <426840E3.8000203@trash.net>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>	 <4252EB9D.9070305@trash.net>	<20050407120417.4297cd14@dxpl.pdx.osdl.net>	 <42628300.9010007@trash.net>	 <20050419110639.47767113@localhost.localdomain>	 <42666098.5060409@trash.net>	 <20050421132020.41858bc4@localhost.localdomain>	 <426832E1.7020003@trash.net>	 <20050422092221.4950e23c@localhost.localdomain>	 <426839B4.2090502@trash.net> <1114128336.10572.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114128336.10572.12.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Duplication of packets would be trivial to do with mirred mirror option
> attached to the qdisc.

The problem with duplication and queueing to the device is that
the packet needs to take the same classification-path as the
original packet to end up in the same leaf-queue. This can only
be guaranteed by restricting which classifiers can be used.

Regards
Patrick
