From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] ipv4: fix for ip_options_rcv_srr() daddr update.
Date: Tue, 15 Nov 2011 16:29:59 +0800
Message-ID: <4EC22307.1000408@cn.fujitsu.com>
References: <4EC21427.9080008@cn.fujitsu.com>	<20111115.022835.551127337110017182.davem@davemloft.net>	<4EC21A01.90702@cn.fujitsu.com> <20111115.032343.1203870624086709786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50445 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753604Ab1KOI3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 03:29:35 -0500
In-Reply-To: <20111115.032343.1203870624086709786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> My long term plan is to eliminate cached routes, we will directly use
> routing table entries instead.
> 
> In such a scheme, the member rt->rt_dst will no longer even exist.
> 
> This is what I've been working towards for more than a year, it is a
> slow and very difficult transformation.
> 
> If you starting adding rt->rt_dst references back, we are taking
> steps backwards.
> 
> 

Thank you, I got it. 

I'll do my best to fix it but without any promise, because i am a kernel
newbie :D
