From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v10 10/11] vxlan: respect scope_id for ll addr
Date: Fri, 30 Aug 2013 16:10:50 +0800
Message-ID: <1377850250.2591.8.camel@cr0>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
	 <1377667379-2315-11-git-send-email-amwang@redhat.com>
	 <OF231098A1.4B9DE99C-ON85257BD6.0074456A-85257BD6.00754552@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754387Ab3H3IK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 04:10:59 -0400
In-Reply-To: <OF231098A1.4B9DE99C-ON85257BD6.0074456A-85257BD6.00754552@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-29 at 17:20 -0400, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 08/28/2013 01:22:58 AM:
> 
> > From: Cong Wang <amwang@redhat.com>
>  
> > As pointed out by David, we should take care of scope id for ll
> > addr, and use it for route lookup.
> 
>         It is an error to have a zero scope_id for an LL addr, but
> this code is not correct, because it only honors scope_id for
> LL addrs. Multicast addresses also require scope_id be set.
>         This shouldn't be in the transmit path. The netlink code
> that sets it should require it be nonzero for LL addrs and multicast
> addrs when it is set, and the transmit path should *always* use scope_id,
> whether for an lladdr or not, whether scope_id is zero or not.
> 

Except multicast address, I think this is what I did in some version
before? It is you who told me to respect scope id on tx path for
routing... I am really tired of changing it back again and again...

I will drop this patch and let you fix it by yourself later.

Thanks!
