From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6 1/4] rtnetlink: implement setting of master
 device
Date: Wed, 16 Feb 2011 05:18:44 -0800
Message-ID: <20110216051844.53f577d5@s6510>
References: <20110213193105.GD2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47344 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab1BPNSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Feb 2011 08:18:49 -0500
In-Reply-To: <20110213193105.GD2740@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Feb 2011 20:31:06 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> This patch allows userspace to enslave/release slave devices via netlink
> interface using IFLA_MASTER. This introduces generic way to add/remove
> underling devices.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

But, setting master means something different for each type of device?
What happens if you move eth0 from br0 to bond0?

The name "master" is only used in the bonding spec. It is not used in
description of bridges in the 802.1 spec. There are also some companies
that have very "politically correct" HR departments that think that any
reference to master or slave is racist.


