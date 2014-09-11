From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 06/16] net: sched: fw use RCU
Date: Wed, 10 Sep 2014 18:03:13 -0700
Message-ID: <1410397393.7106.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910154903.2036.86240.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:51642 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834AbaIKBDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 21:03:14 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so8748621pab.38
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 18:03:14 -0700 (PDT)
In-Reply-To: <20140910154903.2036.86240.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:49 -0700, John Fastabend wrote:
> RCU'ify fw classifier.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_fw.c |  111 ++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 77 insertions(+), 34 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
