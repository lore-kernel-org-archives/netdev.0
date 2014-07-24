From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nf_sockopt_find() should return ERESTARTSYS
Date: Thu, 24 Jul 2014 22:35:05 +0200
Message-ID: <1406234105.3363.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406155995.3363.19.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <3ff5bf70-5db3-4dc4-9f02-abb07843ab81@email.android.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-07-24 at 18:19 +0100, Patrick McHardy wrote:
> On 23. Juli 2014 23:53:15 GMT+01:00, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >From: Eric Dumazet <edumazet@google.com>
> >
> >getsockopt() or setsockopt() sometimes returns -EINTR instead of
> >-ENOPROTOOPT, causing headaches to application developers.
> >
> >This is because unsupported commands might go through nf_sockopt_find()
> >and this function returns -EINTR instead of -ERESTARTSYS if
> >a signal is pending.
> >
> 
> I'd propose to simply use the non interruptable mutex functions. We
> have many instances where this is really completely unnecessary.
> 
> I can take care of this (once my notebook has been repaired).

No problem I'll send a v2, thanks.


