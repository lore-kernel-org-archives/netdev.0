From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] flow_dissector: add support for dst,
 hop-by-hop and routing ext hdrs
Date: Fri, 12 Jun 2015 19:15:35 -0700
Message-ID: <20150613021534.GA9942@Alexeis-MacBook-Pro.local>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
 <1434124866-3881537-3-git-send-email-tom@herbertland.com>
 <20150613012752.GA9895@Alexeis-MacBook-Pro.local>
 <1434159454.27504.101.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150613015004.GA9918@Alexeis-MacBook-Pro.local>
 <1434161476.27504.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Tom Herbert <tom@herbertland.com>,
	edumazet@google.com, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35082 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466AbbFMCPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 22:15:38 -0400
Received: by pacyx8 with SMTP id yx8so31536381pac.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 19:15:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434161476.27504.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2015 at 07:11:16PM -0700, Eric Dumazet wrote:
> On Fri, 2015-06-12 at 18:50 -0700, Alexei Starovoitov wrote:
> 
> > 
> > sure, that's better.
> > If you're going to submit it officialy, please add my Tested-by.
> > My server is happy now :)
> 
> Sure , will do.
> 
> I tried adding __must_check to __skb_header_pointer() but apparently had
> to use W=1 to get a warning :

that is great idea still. At least buildbot can pick it up.
