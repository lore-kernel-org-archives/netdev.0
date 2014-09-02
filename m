From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for anycast
 and multicast
Date: Tue, 2 Sep 2014 09:43:20 -0700
Message-ID: <CAM_iQpWs804KO4pNM302uc__i90MgUBHODA2cofWQTvCCx74jw@mail.gmail.com>
References: <CA+ydwtoDwQVg_BWrxxdpUyJ7Up60GtxTCLYe_5vFdV2td_kGhQ@mail.gmail.com>
	<CAHA+R7MZCDGRhSf=UuVCGQvNo03wVziZQB_X30rwNf6hmHipQA@mail.gmail.com>
	<20140829195339.GA9780@kria>
	<1409363489.2980.17.camel@localhost>
	<20140830105821.GB18155@kria>
	<1409599348.21965.6.camel@localhost>
	<20140901210520.GB25543@kria>
	<1409610378.21965.52.camel@localhost>
	<20140902082929.GA8483@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <cwang@twopensource.com>,
	Tommi Rantala <tt.rantala@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, trinity@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <trinity-owner@vger.kernel.org>
In-Reply-To: <20140902082929.GA8483@kria>
Sender: trinity-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 2, 2014 at 1:29 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
>
> v2:
>  - based on net
>  - keep dev_get_by_flags_rcu and RCU in ipv6_sock_ac_*
>  - remove two ASSERT_RTNL() that are not necessary

There is no point to keep RCU here. Hannes' reply doesn't make
any sense.
