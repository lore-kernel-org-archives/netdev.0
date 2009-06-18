From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 18 Jun 2009 10:01:27 +0800
Message-ID: <4A399FF7.5060209@cn.fujitsu.com>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>	<20090611.021347.142243970.davem@davemloft.net>	<20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>	<6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>	<20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>	<20090615101919.GC7768@bombadil.infradead.org> <20090617094907.e8cd77bd.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@infradead.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, hadi@cyberus.ca,
	tgraf@suug.ch, Paul Menage <menage@google.com>,
	David Miller <davem@davemloft.net>, jarkao2@gmail.com
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56287 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbZFRB7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 21:59:52 -0400
In-Reply-To: <20090617094907.e8cd77bd.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minoru Usui wrote:
> On Mon, 15 Jun 2009 06:19:19 -0400
> Thomas Graf <tgraf@infradead.org> wrote:
> 
>> On Mon, Jun 15, 2009 at 12:00:35PM +0900, Minoru Usui wrote:
>>> Actually, In tc <-> kernel I/F (which uses netlink), tc sets classid to hexadecimal style not X:Y style.
>>> X:Y style is result of translating by tc command.
>>>
>>> I thought this patch was very useful at first, but it's not necessary to implementing to the kernel.
>>> This function can be implemented on user space if we need.
>>> And we can also keep compatibility of net_cls.classid I/F. :-)
>>>
>>> I drop this patch. I'm sorry for confusing a lot of people.
>> I found this patch to be extremely useful if it wasn't to break
>> compatibility but that issue can be resolved by accepting both
>> formats easly.
> 
> Thank you for agreeing my patch.
> 
> I think you said write format only. Am I right?
> What do you think about read format?
> Do you think you should keep read format as current implementation?
> 
> I think we should need to unify read/write format, if we make cls_cgroup is more userfriendly. 
> Because some of people are confused about having to read their write value as different format.
> (Unfortunately, current implementation is so...)
> 
> But this approach breaks compatibility, so I drop this patch.

How about adding a new control file net_cls.tc_classid?

