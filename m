From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH v2 0/2] Fix the SELinux dynamic network access controls
Date: Fri, 24 May 2013 14:20:23 -0400
Message-ID: <2018143.PsiGxnXVKA@sifl>
References: <20130524181430.24022.15997.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26057 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757269Ab3EXSU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 May 2013 14:20:27 -0400
In-Reply-To: <20130524181430.24022.15997.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, May 24, 2013 02:16:16 PM Paul Moore wrote:
> A bump to v2 to incorporate Sergei's minor comment on the previous
> patchset.  I've also gone ahead and dropped the "RFC" from the
> patchset as I didn't see any significant comments/concerns from
> anyone.
> 
> ---
> 
> Paul Moore (2):
>       selinux: fix the labeled xfrm/IPsec reference count handling
>       xfrm: force a garbage collection after deleting a policy

Hi Dave, Eric,

I think we need to get this in for 3.10, assuming no objections from either 
one of you, who wants to pull it into their tree?

-Paul

P.S. Technically this could also be -stable material but I'm not pushing for 
that as this isn't really a panic issue, just a nuisance.

-- 
paul moore
security and virtualization @ redhat
