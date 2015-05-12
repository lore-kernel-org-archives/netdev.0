From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH][next] xfrm: optimise xfrm_policy_lookup_bytype
Date: Tue, 12 May 2015 13:37:47 +0200
Message-ID: <20150512113742.GV8928@secunet.com>
References: <1431170257-18242-1-git-send-email-roy.qing.li@gmail.com>
 <20150511120616.GS8928@secunet.com>
 <CAJFZqHywcxDx1vLTtTqVfVe6hoG1M8PYH4a-7HZ9XrFJPAM-Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50670 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753194AbbELLhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 07:37:53 -0400
Content-Disposition: inline
In-Reply-To: <CAJFZqHywcxDx1vLTtTqVfVe6hoG1M8PYH4a-7HZ9XrFJPAM-Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 04:25:07PM +0800, Li RongQing wrote:
> On Mon, May 11, 2015 at 8:06 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> >
> > priority is initialized with ~0U at the beginning of this function.
> > What if someone has an inexact policy with priority ~0U configured?
> > With your change, this policy will never match because we don't even
> > try to search for it.
> 
> The original code can not handle this kind of policy whose priority is ~0U,

Right, these kind of policies are currently not enforced.

> I will fix it when resubmit this patch.

OK, thanks!
