From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] ipv6: delete protocol when cleanup
Date: Tue, 18 Nov 2014 11:46:30 -0800
Message-ID: <CAHA+R7OUBqy+vE9my4XFnk6S7gYjDrK+5Cmx9H8G=UvLXtL6HA@mail.gmail.com>
References: <546B20F8.6010806@cn.fujitsu.com>
	<CAHA+R7PNmac7KQpSK-vO9zVd3+926f6n_GpaGrbpBnSn98xiyQ@mail.gmail.com>
	<1416338055.14060.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:59306 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbaKRTqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 14:46:31 -0500
Received: by mail-qc0-f172.google.com with SMTP id m20so5346184qcx.17
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 11:46:30 -0800 (PST)
In-Reply-To: <1416338055.14060.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 11:14 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-11-18 at 10:56 -0800, Cong Wang wrote:
>> On Tue, Nov 18, 2014 at 2:35 AM, Duan Jiong <duanj.fnst@cn.fujitsu.com> wrote:
>> >
>> > pim6_protocol was added when initiation, but it not deleted.
>> >
>> > Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>
> ...
>
>> Looks like rtnl_unregister() is missing as well.
>
> Is it really worth bothering ?
>
> May I remind you we took the decision one year ago to not bother about
> removing ipv6 module.
>

It is still called in error path of init, so just for completeness.
