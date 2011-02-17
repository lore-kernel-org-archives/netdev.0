From: Tom Herbert <therbert@google.com>
Subject: Re: state of rtcache removal...
Date: Wed, 16 Feb 2011 18:59:35 -0800
Message-ID: <AANLkTi=W=1ZiP4JOJwo=FccNA9aK=1bpRn=zkepXXMzi@mail.gmail.com>
References: <20110216.160838.39164069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:13768 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189Ab1BQC7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 21:59:40 -0500
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p1H2xdv9013008
	for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 18:59:39 -0800
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz29.hot.corp.google.com with ESMTP id p1H2xaZA025561
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 18:59:36 -0800
Received: by pzk5 with SMTP id 5so319452pzk.3
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 18:59:35 -0800 (PST)
In-Reply-To: <20110216.160838.39164069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 16, 2011 at 4:08 PM, David Miller <davem@davemloft.net> wrote:
>
> So I've been testing out the routing cache removal patch to see
> what the impact is on performance.
>
Interesting results.

I assume that this test is purposely using sento on a connected socket
to force sendmsg to go through the route lookup :-), so this is
showing what the benefits of rtcache are is when cache hit rate is
100%.  For comparison, it might interesting to see what the
performance is when rate is < 100%.  For instance, we often see hit
rates < 20% on front end servers.  This could be done flooding to
random addresses in 10/8 or even 0/0...  I'm hoping that without the
rtcache performance actually improves in that case!

Tom
