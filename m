From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 12:25:33 +0100
Message-ID: <1289561133.3185.123.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	 <20101112071323.GB5660@cr0.nay.redhat.com>
	 <1289546874.17691.1774.camel@edumazet-laptop>
	 <AANLkTikHjGkq5FDoXHaUbRkpurmT3mSLiu8toqqRL4Gi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikHjGkq5FDoXHaUbRkpurmT3mSLiu8toqqRL4Gi@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 12 novembre 2010 =C3=A0 19:10 +0800, Cypher Wu a =C3=A9crit=
 :

> I used to using that way, just seperate the call internal and
> external, with external one hold lock then call the internal one. But
> in that case ip_check_mc() is called indirectly from igmpv3_sendpack(=
)
> and is not very clear how to give the different paramter?

I said that I was preparing a RCU patch, dont bother with this ;)

Should be ready in a couple of minutes.

Thanks
