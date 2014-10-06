From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v1 2/3] net: sched: cls_cgroup tear down exts and
 ematch from rcu callback
Date: Mon, 6 Oct 2014 10:01:40 -0700
Message-ID: <CAHA+R7NszfZUZOmTQD9a47Oaqa3zhOAhOdx05Uu89=_=Nks25A@mail.gmail.com>
References: <20141006042335.6010.27000.stgit@nitbit.x32>
	<20141006042819.6010.32857.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:62694 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbaJFRBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 13:01:42 -0400
Received: by mail-lb0-f179.google.com with SMTP id l4so4542724lbv.24
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 10:01:41 -0700 (PDT)
In-Reply-To: <20141006042819.6010.32857.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 5, 2014 at 9:28 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> It is not RCU safe to destroy the action chain while there
> is a possibility of readers accessing it. Move this code
> into the rcu callback using the same rcu callback used in the
> code patch to make a change to head.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Cong Wang <cwang@twopensource.com>
