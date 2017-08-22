From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: sched: use kvmalloc() for class hash tables
Date: Tue, 22 Aug 2017 14:21:53 -0700
Message-ID: <20170822212151.cf62aebehcjpsbc7@ast-mbp>
References: <1503430006.2499.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36434 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751831AbdHVVV4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:21:56 -0400
Received: by mail-pg0-f68.google.com with SMTP id y129so28280241pgy.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 14:21:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503430006.2499.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 12:26:46PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> High order GFP_KERNEL allocations can stress the host badly.
> 
> Use modern kvmalloc_array()/kvfree() instead of custom
> allocations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks for fixing these issues.
Acked-by: Alexei Starovoitov <ast@kernel.org>
