From: Andi Kleen <ak@suse.de>
Subject: Re: [Xen-devel] [RFC PATCH 34/35] Add the Xen virtual =?utf-8?q?network=09device=09driver=2E?=
Date: Tue, 9 May 2006 15:14:28 +0200
Message-ID: <200605091514.29205.ak@suse.de>
References: <E1FdRpp-0008HG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	chrisw@sous-sol.org, ian.pratt@xensource.com,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:55684 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750974AbWEINOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 09:14:36 -0400
To: virtualization@lists.osdl.org
In-Reply-To: <E1FdRpp-0008HG-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 May 2006 15:01, Herbert Xu wrote:
> Christian Limpach <Christian.Limpach@cl.cam.ac.uk> wrote:
> > 
> > There's at least two reasons why having it in the driver is preferable:
> > - synchronizing sending the fake ARP request with when the device is
> >  operational -- you really want to make this well synchronized to keep
> >  unreachability as short as possible, especially when doing live
> >  migration
> > - anybody but the guest might not know (all) the MAC addresses for which
> >  to send a fake ARP request
> 
> Sure.  However, what's there to stop you from doing this in user-space
> inside the guest?

I guess they don't trust user space. But the standard ipup script
from iproute2 does this already so at least for modern distributions
it should just work.

-Andi
