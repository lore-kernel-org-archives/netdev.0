From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 11/13] net: sched: pfifo_fast use alf_queue
Date: Fri, 19 Aug 2016 12:13:03 +0200
Message-ID: <20160819121303.50963024@redhat.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
        <20160817193810.27032.27544.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        davem@davemloft.net, brouer@redhat.com,
        "Michael S. Tsirkin" <mst@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49782 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753988AbcHSKNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 06:13:09 -0400
In-Reply-To: <20160817193810.27032.27544.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Aug 2016 12:38:10 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> This converts the pfifo_fast qdisc to use the alf_queue enqueue and
                                                ^^^^^^^^^
> dequeue routines then sets the NOLOCK bit.
> 
> This also removes the logic used to pick the next band to dequeue from
> and instead just checks each alf_queue for packets from top priority
                               ^^^^^^^^^
> to lowest. This might need to be a bit more clever but seems to work
> for now.

You need to fix the description, as you are no longer using my
alf_queue implementation but instead are using the skb_array/ptr_ring
queue (by MST).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
