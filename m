From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [CAN] [RFC] skb->iif usage and vcan driver background
Date: Sun, 24 Jun 2007 18:51:38 +0200
Message-ID: <467EA11A.7040109@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>, j.hadi123@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:44809 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbXFXQwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 12:52:23 -0400
In-Reply-To: <467D3891.4010906@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Patrick and Jamal,

as i felt a bit misunderstood in the discussion about the usage of
skb->iif and the idea behind the virtual CAN driver i created four
PDF-slides to clarify some issues. The slides may give you the
appropriate background why the incoming (receiving) interface is
relevant at user level (which is unusual e.g. for PF_INET). Additionally
i collected some points what the VCAN driver does - and especially what
it is not for. So you will see, that approaches like VLAN (regarding
IEEE 802.1Q) is nothing that can be done with the CAN bus by design. The
PDF can be found at the BerliOS OSS server:

http://download.berlios.de/socketcan/iif_and_vcan.pdf

After reading the PDF ...

@Jamal: Please give me some feedback, if the (currently implemented)
transport of the iif-information inside the skb up to socket level is ok
for you.

@Patrick: The (optional) loading of the vcan module and the
specification of the needed number of vcan devices (for the wanted
use-case) was a very easy thing up to now that did not require any
additional configuration nor additional userspace tools (except saying
'ifconfig vcan0 up'). As only the use-case required number of interfaces
are allocated at module load time, i do not see a need for an extra
netlink interface to implement an IMHO obsolete vcan add/remove
mechanism. What could the implementation of the netlink API bring for
the vcan driver use-case?

Thanks for your review!
Oliver


