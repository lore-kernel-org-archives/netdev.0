From: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 23:30:05 +1000
Message-ID: <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown> <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop> <4E3258E1.6020000@fastmail.fm> <20110729103634.GA12050@infradead.org> <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm> <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0 (iPhone Mail 7C144)
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Sent from my iPhone

On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Le vendredi 29 juillet 2011 =C3=A0 21:58 +1000, Greg Banks a =C3=A9cr=
it :
>
>>
>> Sure, and a whole lot of the callsites are ("..._%d", cpu), hence th=
e
>> unfortune :(
>
> BTW, we could name nfsd threads differently :
>
> Currently, they all are named : "nfsd"
>
> If SVC_POOL_PERCPU is selected, we could name them :
> nfsd_c0 -> nfsd_cN
>
> If SVC_POOL_PERNODE is selected, we could name them :
> nfsd_n0  -> nfsd_nN
>
> That would help to check with "ps aux" which cpu/nodes are under =20
> stress.
>
>

I like it!

>

Greg.--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
