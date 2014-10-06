From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: remove tcf_proto from ematch calls
Date: Mon, 6 Oct 2014 09:52:56 -0700
Message-ID: <CAHA+R7PviBvX6xjA7wPxiQ7RDJ3AfbN5rNQFdSfV4ROhVGt6Zw@mail.gmail.com>
References: <20141006042335.6010.27000.stgit@nitbit.x32>
	<20141006042751.6010.86647.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:58457 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961AbaJFQw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 12:52:58 -0400
Received: by mail-la0-f50.google.com with SMTP id s18so4732348lam.23
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 09:52:56 -0700 (PDT)
In-Reply-To: <20141006042751.6010.86647.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 5, 2014 at 9:27 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> This removes the tcf_proto argument from the ematch code paths that
> only need it to reference the net namespace. This allows simplifying
> qdisc code paths especially when we need to tear down the ematch
> from an RCU callback. In this case we can not guarentee that the
> tcf_proto structure is still valid.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

The code looks cleaner now. :)

Acked-by: Cong Wang <cwang@twopensource.com>
