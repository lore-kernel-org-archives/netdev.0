From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: use for_each_netdev_safe() in rtnl_group_changelink()
Date: Tue, 24 Mar 2015 10:19:13 -0700
Message-ID: <CAM_iQpVEKC5JaPqQGwZTqQahuRizJzzL4z_4U2bpQhMntS5fyA@mail.gmail.com>
References: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427157352.25985.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150324.130316.1992586825650098426.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33544 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798AbbCXRTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:19:14 -0400
Received: by pabxg6 with SMTP id xg6so219103709pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 10:19:13 -0700 (PDT)
In-Reply-To: <20150324.130316.1992586825650098426.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 10:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 23 Mar 2015 17:35:52 -0700
>
>> It seems this bug was added in commit e7ed828f10bd8, right ?
>>
>> Fixes: e7ed828f10bd8 ("netlink: support setting devgroup parameters")
>
> I added this to the commit message, thanks.

Thanks for fixing it!
