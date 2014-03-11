From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Tue, 11 Mar 2014 13:53:03 -0700
Message-ID: <1394571183.21721.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140311.163642.197791800524216561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, xiyou.wangcong@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:40374 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbaCKUxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:53:10 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so77836pbb.31
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 13:53:10 -0700 (PDT)
In-Reply-To: <20140311.163642.197791800524216561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 16:36 -0400, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Mon, 10 Mar 2014 10:03:22 -0700
> 
> > This series drops the qdisc lock that is currently protecting the
> > ingress qdisc. This can be done after the tcf filters are made
> > lockless and the statistic accounting is safe to run without locks.
> 
> This series looks great, nice work.
> 
> Please address Eric Dumazet's feedback and repost, then I'd like to
> see Jamal and Cong at least give a cursory review before I apply this.

Yep, I'll redo a full review, this is finally happening, very nice job
John !
