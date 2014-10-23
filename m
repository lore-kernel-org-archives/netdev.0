From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 06:21:30 -0700
Message-ID: <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5448A72D.1050806@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	Crestez Dan Leonard <cdleonard@gmail.com>,
	netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:40233 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbaJWNVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 09:21:31 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so282291pdi.16
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 06:21:31 -0700 (PDT)
In-Reply-To: <5448A72D.1050806@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 02:58 -0400, Jonathan Toppins wrote:

> > +		if (!pool) {
> > +			pool = kzalloc_node(sizeof(*pool), GFP_KERNEL,
> GFP_DMA | GFP_KERNEL
> This memory will possibly be used in a DMA correct? (thinking crypto
> hardware offload)

I am not sure this is the case, but this certainly can be added.
