From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix cwnd limited checking to improve
 congestion control
Date: Fri, 02 May 2014 15:05:43 -0700
Message-ID: <1399068343.2140.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398874919.29914.175.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1398884293.29914.181.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140502.175546.28469480433554767.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58075 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbaEBWFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 18:05:45 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so3364198pab.33
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 15:05:45 -0700 (PDT)
In-Reply-To: <20140502.175546.28469480433554767.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-02 at 17:55 -0400, David Miller wrote:

> Indeed, once you remove the in_flight parameter from tcp_is_cwnd_limited()
> you can subsequently delete it from the ->cong_avoid() method signature
> and implementations.

Yes, I'll submit the cleanup shortly.

Thanks David.
