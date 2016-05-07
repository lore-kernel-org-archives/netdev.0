From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] net: make sch_handle_ingress() drop monitor
 ready
Date: Fri, 6 May 2016 17:18:28 -0700
Message-ID: <20160507001826.GA4184@ast-mbp.thefacebook.com>
References: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36598 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722AbcEGASd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 20:18:33 -0400
Received: by mail-pa0-f43.google.com with SMTP id bt5so51917075pac.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 17:18:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1462575350.13075.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2016 at 03:55:50PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> TC_ACT_STOLEN is used when ingress traffic is mirred/redirected
> to say ifb.
> 
> Packet is not dropped, but consumed.
> 
> Only TC_ACT_SHOT is a clear indication something went wrong.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
