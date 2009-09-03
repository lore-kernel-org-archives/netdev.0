From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Subject: Re: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 3 Sep 2009 15:28:30 +0200
Message-ID: <c4e36d110909030628j53cc0abfq6c1eef7e5e97565b@mail.gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>
	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>
	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>
	 <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>
	 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>
	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
	 <4A9EEF07.5070800@gmail.com>
	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
	 <4A9F1620.2080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753879AbZICN2c@vger.kernel.org>
In-Reply-To: <4A9F1620.2080105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/9/3 Eric Dumazet <eric.dumazet@gmail.com>:
> Zdenek Kabelac a =E9crit :
>>
>> Well I'm not noticing any ill behavior - also note - rcu_barrier() i=
s
>> there before the cache is destroyed.
>> But as I said - it's just my shot into the dark - which seems to wor=
k for me...
>>
>
> Reading again your traces, I do believe there are two bugs in slub
>
> Maybe not explaining your problem, but worth to fix !
>
> Thank you
>
> [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
>


Ok - I can confirm that this patch fixes my reboot problem.

Thanks

Zdenek
