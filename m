From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for
 anycast and multicast
Date: Fri, 05 Sep 2014 12:25:39 -0700 (PDT)
Message-ID: <20140905.122539.670916286627732128.davem@davemloft.net>
References: <CAHA+R7M1qd5g1ta=YFqefgXDf1EfF2_VsJGUvH6Dd+ttnHc_VQ@mail.gmail.com>
	<1409944376.5306.9.camel@localhost>
	<CAHA+R7NSu=wjGsmLapjM4Mbk_oeZ07P+yN0b982otvjoW2jodA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, sd@queasysnail.net,
	tt.rantala@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trinity@vger.kernel.org,
	davej@redhat.com
To: cwang@twopensource.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHA+R7NSu=wjGsmLapjM4Mbk_oeZ07P+yN0b982otvjoW2jodA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <cwang@twopensource.com>
Date: Fri, 5 Sep 2014 12:23:37 -0700

> On Fri, Sep 5, 2014 at 12:12 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>>
>> What games are you playing? You know how patches are processed by David
>> and I even let him the choice by pointing out a problem in your patch so
>> that you could an update and send v2.
> 
> I assume David goes over all the discussion before applying any patch.
> So in the original discussion, obviously I disagree with your point on RCU,
> and sent my own version.

I thought the retention of RCU locking was reasonable, and that your
feedback was something I disagreed with.

This is different from ignoring your feedback.
