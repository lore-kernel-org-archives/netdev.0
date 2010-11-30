From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] m_xt: stop using xtables_set_revision()
Date: Tue, 30 Nov 2010 09:49:12 -0800
Message-ID: <20101130094912.3843e120@nehalam>
References: <1290374214-26743-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50451 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466Ab0K3RtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 12:49:19 -0500
In-Reply-To: <1290374214-26743-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 Nov 2010 16:16:54 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> iptables dropped the xtables_set_revision() function around version 1.4.9,
> so set the rev directly ourselves.  This should be compatible back to the
> original version m_xt itself is designed for.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  tc/m_xt.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/tc/m_xt.c b/tc/m_xt.c
> index bfc4937..ede9913 100644
> --- a/tc/m_xt.c
> +++ b/tc/m_xt.c
> @@ -88,7 +88,7 @@ build_st(struct xtables_target *target, struct xt_entry_target *t)
>  		target->t = xtables_calloc(1, size);
>  		target->t->u.target_size = size;
>  		strcpy(target->t->u.user.name, target->name);
> -		xtables_set_revision(target->t->u.user.name, target->revision);
> +		target->t->u.user.revision = target->revision;
>  
>  		if (target->init != NULL)
>  			target->init(target->t);


Applied.
