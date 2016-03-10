From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 17:36:30 -0500 (EST)
Message-ID: <20160310.173630.525547775491939864.davem@davemloft.net>
References: <20160310.160521.1642655131932337300.davem@davemloft.net>
	<20160310211945.GD1989@uranus.lan>
	<20160310215959.GE1989@uranus.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, solar@openwall.com,
	vvs@virtuozzo.com, avagin@virtuozzo.com, xemul@virtuozzo.com,
	vdavydov@virtuozzo.com, khorenko@virtuozzo.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160310215959.GE1989@uranus.lan>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Fri, 11 Mar 2016 00:59:59 +0300

> On Fri, Mar 11, 2016 at 12:19:45AM +0300, Cyrill Gorcunov wrote:
>> > 
>> > Oh yes they do, from masq's non-inet notifier.  masq registers two
>> > notifiers, one for generic netdev and one for inetdev.
>> 
>> Thanks a huge David! I'll test it just to be sure.
> 
> Works like a charm! So David, what are the next steps then?
> Mind to gather all your patches into one (maybe)?

I'll re-review all of the changes tomorrow and also look into ipv6
masq, to see if it needs the same treatment, as well.

Thanks for all of your help and testing so far.
