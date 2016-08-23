From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 3/3] net/sched: Introduce act_iptunnel
Date: Tue, 23 Aug 2016 18:15:38 +0200
Message-ID: <20160823181538.3ca7f700@griffin>
References: <20160822143834.32422-1-amir@vadai.me>
        <20160822143834.32422-4-amir@vadai.me>
        <CAJ3xEMhTdNXXLQfvD097_7LEK8YRTXW_r+ArB-XksX6dRvUAjg@mail.gmail.com>
        <20160822205137.30cda14f@griffin>
        <20160823152805.GA12627@office.localdomain>
        <20160823173349.2b64b466@griffin>
        <20160823160537.GB12627@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753294AbcHWQPn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 12:15:43 -0400
In-Reply-To: <20160823160537.GB12627@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Aug 2016 19:05:37 +0300, Amir Vadai wrote:
> It is already there - user can use act_mirred and redirect skb's with
> metadata since shared tunnel devices introduced.

You're right, I haven't thought of that.

> The only thing that was added here, is to enable the user to drop the
> metadata, which I think we agree is the ok.

Absolutely. It would be even better if the metadata could be dropped
automatically but I don't see any good place to do it.

> But I agree with you, that I must understand the life cycle of the metadata and dst
> better. I will try to understand it better and explain/fix accordingly.

Thanks!

 Jiri
