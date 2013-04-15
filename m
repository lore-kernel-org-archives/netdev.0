From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Mon, 15 Apr 2013 10:31:20 +0800
Message-ID: <1365993080.5074.5.camel@cr0>
References: <516641CF.4020101@us.ibm.com>
	 <1937058599.2214531.1365659704193.JavaMail.root@redhat.com>
	 <1365724799.3563.5.camel@sridhar.usor.ibm.com>
	 <20130412.151916.63924835658790088.davem@davemloft.net>
	 <516893BD.20303@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31700 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008Ab3DOCbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 22:31:36 -0400
In-Reply-To: <516893BD.20303@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 16:07 -0700, Sridhar Samudrala wrote:
> To address this behavior seen with veth, i had to change the if 
> condition to
> check for rt->dst.dev->flags rather than rt->rt_flags. 

There is no specific IFF_ flag for veth, nor I think introducing one is
a correct fix.

I think we can just revert it for now, since it is not very easy to fix.
You can, of course, send a bug-free version later. This regression
blocks my VXLAN IPv6 support patches, by the way.
