From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 12:22:36 -0700
Message-ID: <1414092156.20845.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5448A72D.1050806@cumulusnetworks.com>
	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54492A2B.2090209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:41451 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071AbaJWTWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 15:22:38 -0400
Received: by mail-pd0-f180.google.com with SMTP id fp1so36888pdb.11
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 12:22:37 -0700 (PDT)
In-Reply-To: <54492A2B.2090209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 19:17 +0300, Crestez Dan Leonard wrote:

> Doesn't virt_to_page also assume that the memory is not from vmalloc?
> 
> Making this portable would require checking if is_vmalloc_addr and doing
> vmalloc_to_page instead. Easier to just kmalloc instead.

Oh right, I'll send a v2

Thanks !
