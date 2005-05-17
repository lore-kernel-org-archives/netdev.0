From: "Manfred Schwarb" <manfred99@gmx.ch>
Subject: Re: 2.4.30-hf1 do_IRQ stack overflows
Date: Tue, 17 May 2005 18:05:47 +0200 (MEST)
Message-ID: <23492.1116345947@www33.gmx.net>
References: <20050514110516.GA1238@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, linux-kernel@vger.kernel.org,
        davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> >
> > Trace; f8b531fc <[reiserfs]reiserfs_insert_item+14c/150>
> > Trace; c02387be <__kfree_skb+fe/160>
> > Trace; c02387be <__kfree_skb+fe/160>
> > Trace; f90dd5f4 <[8139too]rtl8139_start_xmit+84/180>
> 
> Do you have any funky netfilter/iptables modules loaded?

I use a iptables based firewall, but no additional netfilter modules
are loaded. The network configuration is as it is shipped by SuSE
(i.e. no CONFIG_IP_NF_* modules, but most of the "Networking options"
are set to y).
And as I told in an earlier mail, I had scheduling built in
the kernel (CONFIG_NET_SCHED=y, CONFIG_NET_QOS=y, 
CONFIG_NET_ESTIMATOR=y, CONFIG_NET_CLS=y, CONFIG_NET_CLS_ROUTE=y).

I have disabled NET_SCHED now (as Marcelo suggested), and I got no 
overflows since then (4 days uptime).

Seems to work so far.
Thanks and regards,
Manfred



-- 
Weitersagen: GMX DSL-Flatrates mit Tempo-Garantie!
Ab 4,99 Euro/Monat: http://www.gmx.net/de/go/dsl
