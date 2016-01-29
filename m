From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 12:01:36 -0800
Message-ID: <1454097696.7627.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110634.1678121731419241040.davem@davemloft.net>
	 <1454096250.7627.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129194434.GC17127@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36758 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbcA2UBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 15:01:38 -0500
Received: by mail-pa0-f48.google.com with SMTP id yy13so46217933pab.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 12:01:38 -0800 (PST)
In-Reply-To: <20160129194434.GC17127@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 14:44 -0500, Sowmini Varadhan wrote:
> On (01/29/16 11:37), Eric Dumazet wrote:
> > 
> > I have no idea why reading iph->saddr or iph->daddr would not hit the
> > problem, but accessing the 32bit ipv6 flow label would be an issue.
> > 
> > Something is fishy.
> 
> I was wondering about this myself. Even on sparc, I only first
> ran into the errors for ipv6. I dont know if the fact that the
> saddr is memcpy'ed masks the error (even though the problem
> is still there). 

Oh right, recent work in flow dissector added all these memcpy()

I was still looking at linux-4.3 ;)
