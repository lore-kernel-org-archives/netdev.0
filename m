From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Wed, 5 Dec 2012 21:00:36 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr>
References: <1354735339-13402-1-git-send-email-willemb@google.com> <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2012-12-05 20:28, Willem de Bruijn wrote:

>Somehow, the first part of this email went missing. Not critical,
>but for completeness:
>
>These two patches each add an xtables match.
>
>The xt_priority match is a straighforward addition in the style of
>xt_mark, adding the option to filter on one more sk_buff field. I
>have an immediate application for this. The amount of code (in
>kernel + userspace) to add a single check proved quite large.

Hm so yeah, can't we just place this in xt_mark.c?
