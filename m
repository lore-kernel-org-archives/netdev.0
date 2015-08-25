From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv5 net-next 03/10] ipv6: Export nf_ct_frag6_gather()
Date: Tue, 25 Aug 2015 12:15:40 -0700
Message-ID: <CALnjE+raAnSwWsvkVwYkt4qj1f1twN-fZnBGeh1WAuq5hrsGLg@mail.gmail.com>
References: <1440462740-23358-1-git-send-email-joestringer@nicira.com>
	<1440462740-23358-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, pablo <pablo@netfilter.org>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Justin Pettit <jpettit@nicira.com>,
	Jesse Gross <jesse@nicira.com>, netfilter-devel@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33795 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbbHYTPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 15:15:41 -0400
Received: by iodb91 with SMTP id b91so198386427iod.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 12:15:40 -0700 (PDT)
In-Reply-To: <1440462740-23358-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 24, 2015 at 5:32 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>

When I apply this patch I see empty commit msg. I think you need to
add atleast a blank line after the subject.

> ---
> v4: Add ack.
> v5: No change.
> ---
>  net/ipv6/netfilter/nf_conntrack_reasm.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
> index 6d02498..701cd2b 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -633,6 +633,7 @@ ret_orig:
>         kfree_skb(clone);
>         return skb;
>  }
> +EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);
>
>  void nf_ct_frag6_consume_orig(struct sk_buff *skb)
>  {
> --
> 2.1.4
>
