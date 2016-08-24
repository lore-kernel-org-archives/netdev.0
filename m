From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: minor optimization in
 qdisc_qstats_cpu_drop()
Date: Wed, 24 Aug 2016 12:07:27 -0700
Message-ID: <1472065647.14381.113.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
         <f4e3fe14-ddbb-5b37-d003-46f28f7d8750@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34825 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751702AbcHXTTL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:19:11 -0400
Received: by mail-pa0-f66.google.com with SMTP id cf3so1672332pad.2
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 12:19:11 -0700 (PDT)
In-Reply-To: <f4e3fe14-ddbb-5b37-d003-46f28f7d8750@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-24 at 11:04 -0700, Rick Jones wrote:
> On 08/24/2016 10:23 AM, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > per_cpu_inc() is faster (at least on x86) than per_cpu_ptr(xxx)++;
> 
> Is it possible it is non-trivially slower on other architectures?

No, in the worst case, compiler would emit the same code.
