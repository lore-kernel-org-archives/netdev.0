From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kmem_cache_alloc panic in 3.10+
Date: Sat, 18 Jan 2014 08:57:01 -0800
Message-ID: <1390064221.31367.522.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.10.1401180036020.18419@dinf>
	 <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: dormando <dormando@rydia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:54200 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094AbaARQ5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 11:57:03 -0500
In-Reply-To: <1390062576.31367.519.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-18 at 08:29 -0800, Eric Dumazet wrote:

> Hmm...
> 
> Some dst seems to be destroyed twice. This likely screws slab allocator.
> 
> Please try following untested patch :


Forget it, after some coffee it makes no longer sense ;)
