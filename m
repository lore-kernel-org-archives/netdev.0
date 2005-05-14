From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.4.30-hf1 do_IRQ stack overflows
Date: Sat, 14 May 2005 21:05:16 +1000
Message-ID: <20050514110516.GA1238@gondor.apana.org.au>
References: <E1DVyuq-0005Sf-00@gondolin.me.apana.org.au> <21780.1115887477@www69.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.tosatti@cyclades.com, linux-kernel@vger.kernel.org,
	davem@redhat.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262735AbVENLGI@vger.kernel.org>
To: Manfred Schwarb <manfred99@gmx.ch>
Content-Disposition: inline
In-Reply-To: <21780.1115887477@www69.gmx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 10:44:37AM +0200, Manfred Schwarb wrote:
>
> Trace; f8b531fc <[reiserfs]reiserfs_insert_item+14c/150>
> Trace; c02387be <__kfree_skb+fe/160>
> Trace; c02387be <__kfree_skb+fe/160>
> Trace; f90dd5f4 <[8139too]rtl8139_start_xmit+84/180>

Do you have any funky netfilter/iptables modules loaded?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
