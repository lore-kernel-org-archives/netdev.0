From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: [PATCH][2.5] net/core/dev.c readability cleanups
Date: Tue, 11 Jun 2002 14:38:23 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10206111431460.17660-100000@mausmaki.cosy.sbg.ac.at>
References: <20020611.052539.34960972.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ak@muc.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020611.052539.34960972.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Tue, 11 Jun 2002, David S. Miller wrote:

> I don't find this more readable at all. 

the special case for deliver_to_old_ones was cluttering the core, imho
abstracting it by deliver_to proto improves readability of netif_receive_skb
significantly.

> SUPPORT_2_2 is simply crap,
> it isn't 2.2.x anything, it simply means protocols that aren't %100
> SMP safe.

ok, but nevertheless, they should be cleaned up within the 2.5 timeframe.
they are not only not 100% SMP safe, they also don't know what to do with
skb fragments.

> Also "uint" doesn't belong in here and doesn't increase readability at all.
good. so it should be "unsigned int"

> Talk to Arnaldo de Melo if you want to do janitorial work in this
> area, when he sends me cleanups I don't barf.

sure,
i don't take this as barfing, just like some "honest" opinion.


	tm

-- 
in some way i do, and in some way i don't.
