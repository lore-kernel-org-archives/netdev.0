From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/1] Introduction of the tc tests
Date: Tue, 20 Jun 2017 11:36:47 -0400 (EDT)
Message-ID: <20170620.113647.676648925381946650.davem@davemloft.net>
References: <CAM_iQpUxfGrLTv+8J_=n2-zOOd5fqwrNSvF7Ro1EyRyBBNb_8w@mail.gmail.com>
        <20170619.234819.333574326143678552.davem@davemloft.net>
        <CAM_iQpX-9No6RT1KEUJkd_smKjtxUJ1ZiYBwXOHJzR=1t_wBSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucasb@mojatatu.com, netdev@vger.kernel.org,
        stephen@networkplumber.org, jiri@resnulli.us, mrv@mojatatu.com,
        jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36000 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbdFTPgu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 11:36:50 -0400
In-Reply-To: <CAM_iQpX-9No6RT1KEUJkd_smKjtxUJ1ZiYBwXOHJzR=1t_wBSA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 19 Jun 2017 21:13:31 -0700

> I thought tools/testing/selftests/ is mainly for those tests close to
> kernel ABI and API. What is the criteria for these tests? If any test
> can fit in, we somehow would merge the whole LTP...
> 
> I definitely don't object more tests, I am just wondering if we should
> put it to tools/testing/selftests/ or host it somewhere else.

I want it in the kernel so that it gets the level of exposure, care,
review, and use that the kernel does.

If you put it somewhere else it gets at least 10 times less of all
of those attributes.
