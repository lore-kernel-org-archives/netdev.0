From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [Patch net-next] net_sched: only create filter chains for new
 filters/actions
Date: Fri, 26 May 2017 07:53:52 +0200
Message-ID: <20170526055352.GA1898@nanopsycho>
References: <1495557757-31371-1-git-send-email-xiyou.wangcong@gmail.com>
 <20170525.121456.221336477222052018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com,
        jiri@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36119 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965226AbdEZFxz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 01:53:55 -0400
Received: by mail-wm0-f66.google.com with SMTP id k15so1456623wmh.3
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 22:53:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170525.121456.221336477222052018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, May 25, 2017 at 06:14:56PM CEST, davem@davemloft.net wrote:
>From: Cong Wang <xiyou.wangcong@gmail.com>
>Date: Tue, 23 May 2017 09:42:37 -0700
>
>> tcf_chain_get() always creates a new filter chain if not found
>> in existing ones. This is totally unnecessary when we get or
>> delete filters, new chain should be only created for new filters
>> (or new actions).
>> 
>> Fixes: 5bc1701881e3 ("net: sched: introduce multichain support for filters")
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Cc: Jiri Pirko <jiri@mellanox.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>Indeed, get and delete requests should not create new objects, ever.
>
>I have pretty much no idea why Jiri is making such a big fuss about
>this change, to be quite honest. :-)

Because it makes already hard to read code even worse, for *no* benefit.
That's why.


>
>Applied, thanks Cong.
