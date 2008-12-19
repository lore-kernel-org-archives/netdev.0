From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] net: Fix oops in dev_ifsioc()
Date: Fri, 19 Dec 2008 16:14:54 +0800
Message-ID: <494B57FE.3070706@cn.fujitsu.com>
References: <20081219070431.GA7189@ff.dom.local> <494B552B.1010602@cn.fujitsu.com> <20081219081104.GB7189@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: julia@diku.dk, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58022 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752772AbYLSIPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 03:15:50 -0500
In-Reply-To: <20081219081104.GB7189@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski said the following on 2008-12-19 16:11:
> On Fri, Dec 19, 2008 at 04:02:51PM +0800, Wang Chen wrote:
>> Jarek Poplawski said the following on 2008-12-19 15:04:
>>> A command like this: "brctl addif br1 eth1" issued as a user gave me
>>> an oops when bridge module wasn't loaded. It's caused by using a dev
>>> pointer before checking for NULL.
> ...
>> Subject will be changed, sorry.
>> Seems Julia  is doing "Move a dereference below a NULL test" check,
>> but why the coccinelle missed this one?
> 
> Probably because it's quite fresh?
> 

Yes. Maybe Julia never check the source of -next. :)

