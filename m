From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net_sched: prio: rollback allocations if prio_init() fails
Date: Mon, 13 Jun 2016 10:31:00 -0700
Message-ID: <CAM_iQpUfT-3eLH3rcPCUe9Ujv5+aRdyLKRJZFqA+ryvh926DOg@mail.gmail.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
 <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com> <1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:34576 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752405AbcFMRbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:31:25 -0400
Received: by mail-yw0-f175.google.com with SMTP id c72so131935621ywb.1
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:31:25 -0700 (PDT)
In-Reply-To: <1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 10:27 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-06-13 at 10:13 -0700, Eric Dumazet wrote:
>
>> Presumably we should commit changes on qdisc only if the whole
>> ->change() succeeded, but I guess lot of qdisc are buggy in this
>> respect.

I suppose so, it should work like a transaction.

>
> I'll post a v2 fixing this issue as well.
>
>

Thanks!
