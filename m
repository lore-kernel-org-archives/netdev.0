From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 1/4] rtnetlink: implement setting of master
 device
Date: Wed, 16 Feb 2011 15:39:24 +0100
Message-ID: <20110216143923.GB5727@psychotron.brq.redhat.com>
References: <20110213193105.GD2740@psychotron.redhat.com>
 <20110216051844.53f577d5@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30358 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664Ab1BPOkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Feb 2011 09:40:02 -0500
Content-Disposition: inline
In-Reply-To: <20110216051844.53f577d5@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 16, 2011 at 02:18:44PM CET, shemminger@vyatta.com wrote:
>On Sun, 13 Feb 2011 20:31:06 +0100
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> This patch allows userspace to enslave/release slave devices via netlink
>> interface using IFLA_MASTER. This introduces generic way to add/remove
>> underling devices.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>But, setting master means something different for each type of device?

Why isn't correct to use master also for bridge? It had no meaning there.

>What happens if you move eth0 from br0 to bond0?

you mean by:
ip link set eth0 master br0
ip link set eth0 master bond0

It's first removed from bridge, then added into bond. No problem here.


>
>The name "master" is only used in the bonding spec. It is not used in
>description of bridges in the 802.1 spec. There are also some companies
>that have very "politically correct" HR departments that think that any
>reference to master or slave is racist.
>
>
