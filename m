From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: Add default_advmss() methods to blackhole dst_ops
Date: Fri, 18 Feb 2011 21:29:43 +0800
Message-ID: <AANLkTi=O1LZzSc8=qMX=R3rJpCVL8eWr1eo6NkiZXS0m@mail.gmail.com>
References: <20110218050321.10415.qmail@science.horizon.com>
 <1298010735.2642.9.camel@edumazet-laptop> <1298023023.2595.170.camel@edumazet-laptop>
 <AANLkTi=GRPWNWZuORx1zoJJURE-drqEoMdTuKB9LZ8Ux@mail.gmail.com> <1298035443.6201.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: George Spelvin <linux@horizon.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298035443.6201.51.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 18, 2011 at 9:24 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 18 f=E9vrier 2011 =E0 21:16 +0800, Changli Gao a =E9crit =
:
>
>> I am wondering why magic number 256 is used here. Is there a special
>> reason? Thanks.
>>
>
> It really doesnt matter. SYN message will be dropped anyway.
>
> 256 happens to be the default value
> of /proc/sys/net/ipv4/route/min_adv_mss
>

Thanks for your explaining. IMHO, ip_rt_min_advmss is better than a
magic number, here.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
