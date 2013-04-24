From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Wed, 24 Apr 2013 13:26:24 +0800
Message-ID: <1366781184.3849.10.camel@cr0>
References: <1366701302.21136.19.camel@cr0>
		<20130423.031805.544535198246859192.davem@davemloft.net>
	 <1366702220.21136.23.camel@cr0>
		<20130423.033620.1101068519499870853.davem@davemloft.net>
	 <1366702893.21136.28.camel@cr0> <87d2tlv32i.fsf@nemi.mork.no>
	 <OF8FAF5C90.C6D83D68-ON85257B56.005F1762-85257B56.005FCD21@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161Ab3DXF1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 01:27:20 -0400
In-Reply-To: <OF8FAF5C90.C6D83D68-ON85257B56.005F1762-85257B56.005FCD21@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 13:26 -0400, David Stevens wrote:
> BTW, another thing I thought of after I sent my patch comments -- you
> also need to consider the state of net.ipv6.bindv6only. When v6 is
> enabled, you use one socket for v4 and v6, but if bindv6only=1, you
> actually need a separate socket for v4 receives. If you want to support
> both v4 and v6 with bindv6only=1, you need two sockets. Or even if you
> want to support v4-only VXLAN and the sysadmin has set bindv6only=1.
> 

Good point!

Actually the initial version of my patch did use two sockets for v4 and
v6. I am adding this to my TODO list.

Thanks!
