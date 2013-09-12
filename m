From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix NULL pointer dereference in br_handle_frame
Date: Thu, 12 Sep 2013 08:24:30 -0700
Message-ID: <1378999470.24408.10.camel@edumazet-glaptop>
References: <1378988195-2710-1-git-send-email-zhiguohong@tencent.com>
	  <1378995112.24408.4.camel@edumazet-glaptop>
	  <CAA7+ByWJLUkxy7C0frKOFUscJaQyRLsfk_N=NZfdzUrbZ=4MNA@mail.gmail.com>
	 <1378996396.24408.8.camel@edumazet-glaptop> <5231D2D2.3090907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hong zhi guo <honkiko@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, zhiguohong@tencent.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:62787 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab3ILPYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:24:35 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so10712086pbc.29
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 08:24:35 -0700 (PDT)
In-Reply-To: <5231D2D2.3090907@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-12 at 10:42 -0400, Vlad Yasevich wrote:

> Don't all tests for IFF_BRIDGE_PORT on the bridge receive path become 
> redundant as well?

Sure but anyway this part is net-next material

Lets fix the bug first.

Acked-by: Eric Dumazet <edumazet@google.com>
