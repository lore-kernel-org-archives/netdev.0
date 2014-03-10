From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 02/14] net: rcu-ify tcf_proto
Date: Mon, 10 Mar 2014 10:30:19 -0700
Message-ID: <1394472619.3607.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170407.3011.37150.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:50677 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832AbaCJRaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:30:25 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so7515727pab.24
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:30:23 -0700 (PDT)
In-Reply-To: <20140310170407.3011.37150.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:04 -0700, John Fastabend wrote:

> -	flow->filter_list = NULL;
> +	rcu_assign_pointer(flow->filter_list, NULL);

RCU_INIT_POINTER(flow->filter_list, NULL);

Otherwise, rest of patch seems fine, thanks !
