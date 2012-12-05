From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Wed, 5 Dec 2012 14:28:25 -0500
Message-ID: <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53757 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab2LET24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 14:28:56 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so8833198ieb.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 11:28:55 -0800 (PST)
In-Reply-To: <1354735339-13402-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Somehow, the first part of this email went missing. Not critical,
but for completeness:

These two patches each add an xtables match.

The xt_priority match is a straighforward addition in the style of
xt_mark, adding the option to filter on one more sk_buff field. I
have an immediate application for this. The amount of code (in
kernel + userspace) to add a single check proved quite large.

On Wed, Dec 5, 2012 at 2:22 PM, Willem de Bruijn <willemb@google.com> wrote:
> The second patch is more speculative and aims to be a more general
> workaround, as well as a performance optimization: support
> (preferably JIT compiled) BPF programs as iptables match rules.
>
> Potentially, the skb->priority match can be implemented by applying
> only the second patch and adding a new BPF_S_ANC ancillary field to
> Linux Socket Filters.
>
> I also wrote corresponding userspace patches to iptables. The process
> for submitting both kernel and user patches is not 100% clear to me.
> Sending the kernel bits to both netdev and netfilter-devel for
> initial feedback. Please correct me if you want it another way.
>
> The patches apply to net-next.
>
