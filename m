From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] net: minor optimization in
 qdisc_qstats_cpu_drop()
Date: Thu, 25 Aug 2016 16:45:38 -0700 (PDT)
Message-ID: <20160825.164538.1033966251458899451.davem@redhat.com>
References: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49760 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753912AbcHYXrK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 19:47:10 -0400
In-Reply-To: <1472059414.14381.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Aug 2016 10:23:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> per_cpu_inc() is faster (at least on x86) than per_cpu_ptr(xxx)++;
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
