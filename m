From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 17:23:41 -0400
Message-ID: <200708221723.41802.paul.moore@hp.com>
References: <200708221631.34234.paul.moore@hp.com> <20070822.140805.54950393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jmorris@namei.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tayrelbas01.tay.hp.com ([161.114.80.244]:40377 "EHLO
	tayrelbas01.tay.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933495AbXHVVX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:23:57 -0400
In-Reply-To: <20070822.140805.54950393.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, August 22 2007 5:08:05 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Wed, 22 Aug 2007 16:31:34 -0400
>
> > We're currently talking about several different ideas to solve the
> > problem, including leveraging the sk_buff.secmark field, and one of the
> > ideas was to add an additional field to the sk_buff structure.  Knowing
> > how well that idea would go over (lead balloon is probably an
> > understatement at best) I started looking at what I might be able to
> > remove from the sk_buff struct to make room for a new field (the new
> > field would be a u32).  Looking at the sk_buff structure it appears that
> > the sk_buff.dev and sk_buff.iif fields are a bit redundant and removing
> > the sk_buff.dev field could free 32/64 bits depending on the platform. 
> > Is there any reason (performance?) for keeping the sk_buff.dev field
> > around?  Would the community be open to patches which removed it and
> > transition users over to the sk_buff.iif field?  Finally, assuming the
> > sk_buff.dev field was removed, would the community be open to adding a
> > new LSM/SELinux related u32 field to the sk_buff struct?
>
> It's there for performance, and I bet there might be some semantic
> issues involved.

Okay, thought that was probably the case considering the efforts to shrink the 
sk_buff as much as possible.

> And ironically James Morris still owes me a struct sk_buff removal
> from when I let him put the "secmark" thing in there!
>
> Stop spending money you guys haven't earned yet :-)

Hey, I was just asking how much it cost ... but then again, you know the old 
adage, "if you have to ask, you can't afford it" ;)

Thanks.

-- 
paul moore
linux security @ hp
