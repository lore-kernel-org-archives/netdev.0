From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH rfc] netfilter: two xtables matches
Date: Thu, 6 Dec 2012 06:22:46 +0100
Message-ID: <20121206052246.GA2905@1984>
References: <1354735339-13402-1-git-send-email-willemb@google.com>
 <CA+FuTSeYvcdtNf7N=POD+RzsE01+WVsub6F_nqbn06RZyoWx8w@mail.gmail.com>
 <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Willem de Bruijn <willemb@google.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1212052100190.30908@nerf07.vanv.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 05, 2012 at 09:00:36PM +0100, Jan Engelhardt wrote:
> On Wednesday 2012-12-05 20:28, Willem de Bruijn wrote:
> 
> >Somehow, the first part of this email went missing. Not critical,
> >but for completeness:
> >
> >These two patches each add an xtables match.
> >
> >The xt_priority match is a straighforward addition in the style of
> >xt_mark, adding the option to filter on one more sk_buff field. I
> >have an immediate application for this. The amount of code (in
> >kernel + userspace) to add a single check proved quite large.
> 
> Hm so yeah, can't we just place this in xt_mark.c?

I don't feel this belongs to xt_mark at all.
