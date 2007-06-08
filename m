From: Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>
Subject: Re: [PATCH] Virtual ethernet tunnel (v.2)
Date: Fri, 08 Jun 2007 21:49:17 +0200
Message-ID: <4669B2BD.5060208@gmx.net>
References: <4667E83E.2060405@openvz.org> <466822DD.1000601@candelatech.com>	<466826C6.6000206@openvz.org>	<46682976.8050904@candelatech.com> <46697D0A.40006@openvz.org> <46698B24.2030309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@openvz.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:47722 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750908AbXFHTsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 15:48:51 -0400
In-Reply-To: <46698B24.2030309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.06.2007 19:00, Ben Greear wrote:
> I have another sysfs patch that allows setting a default skb->mark for
> an interface so that you can set the skb->mark
> before it hits the connection tracking logic, but I'm been told this one
> has very little chance
> of getting into the kernel.  The skb->mark patch is only useful (as far
> as I can tell) if you
> also include a patch Patrick McHardy did for me that allowed the
> conn-tracking logic to
> use skb->mark as part of it's tuple.  This allows me to do NAT between
> virtual routers
> (routing tables) on the same machine using veth-equivalent drivers to
> connect the
> routers.  He thinks this will probably not ever get into the kernel either.

Are these patches available somewhere? I'm currently doing NAT between
virtual routers by some advanced iproute2/iptables trickery, but I have
no way to handle the occasional tuple conflict.

Regards,
Carl-Daniel
