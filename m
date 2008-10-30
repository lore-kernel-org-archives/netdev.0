From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/netlabel/netlabel_addrlist.c
Date: Thu, 30 Oct 2008 08:12:39 -0400
Message-ID: <200810300812.39810.paul.moore@hp.com>
References: <ea11fea30810290106u3f92268q62226da65db6f6a4@mail.gmail.com> <200810291543.49225.paul.moore@hp.com> <ea11fea30810291910v1f99b62arcc63285fefe8bf72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "Manish Katiyar" <mkatiyar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:11630 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbYJ3MMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 08:12:42 -0400
In-Reply-To: <ea11fea30810291910v1f99b62arcc63285fefe8bf72@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 29 October 2008 10:10:36 pm Manish Katiyar wrote:
> On Thu, Oct 30, 2008 at 1:13 AM, Paul Moore <paul.moore@hp.com> wrote:
> > On Wednesday 29 October 2008 2:27:44 pm you wrote:
> >> Hi Paul,
> >>
> >> Does this look better ?? Appreciate your help. Patch compile
> >> tested.
> >>
> >> Enable netlabel auditing functions only when CONFIG_AUDIT is set
> >>
> >> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
> >
> > Much better, just some style nits noted below that need to be
> > addressed ...
>
> Hi Paul,
>
> Updated patch below as per your comments.
>
> Enable netlabel auditing functions only when CONFIG_AUDIT is set
>
> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>

Thanks for sticking with this, I appreciate it.  There is still one 
small style nit (see below) but it is really my fault for not being 
more specific.  Unless you object I'll go ahead and fix it up when I 
apply the patch.

I'll send a git pull request out to netdev later today, including your 
patch, as there are two other labeled networking patches that need to 
make the next 2.6.28-rcX release.

> ---
>  net/netlabel/netlabel_addrlist.c |    2 ++
>  net/netlabel/netlabel_addrlist.h |   22 ++++++++++++++++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)
>
> diff --git a/net/netlabel/netlabel_addrlist.c
> b/net/netlabel/netlabel_addrlist.c index b0925a3..3fe73c2 100644
> --- a/net/netlabel/netlabel_addrlist.c
> +++ b/net/netlabel/netlabel_addrlist.c
> @@ -327,6 +327,7 @@ struct netlbl_af6list
> *netlbl_af6list_remove(const struct in6_addr *addr,
>   * Write the IPv4 address and address mask, if necessary, to
> @audit_buf. *
>   */
> +#ifdef CONFIG_AUDIT
>  void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
>                                         int src, const char *dev,
>                                         __be32 addr, __be32 mask)

When I said to move the #ifdef below the comment, I meant below 
the "Audit Helper Functions" comment but before the function's kdoc 
comment header.

-- 
paul moore
linux @ hp
