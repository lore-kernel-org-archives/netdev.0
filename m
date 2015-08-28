From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCH net] netlink: rx mmap: fix POLLIN condition
Date: Fri, 28 Aug 2015 16:00:59 +0900
Message-ID: <20150828070058.GA32596@gmail.com>
References: <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150820055447.GA2656@gmail.com>
 <20150825.201712.2151042716686513603.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35580 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbbH1HBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 03:01:04 -0400
Received: by pacdd16 with SMTP id dd16so52928090pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 00:01:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150825.201712.2151042716686513603.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Thank you for the reply.
 
On Tue, Aug 25, 2015 at 08:17:12PM -0700, David Miller wrote:
> So if netlink_forward_ring() _actually_ sees an entry that we should
> advance past, it will cycle through the whole ring, advancing ring->head
> until it equals the "ring->head != head" loop test fails.
> 
> We should definitely fix this bug first.

I should have realized it, sorry. I think the following patch will
fix it, would you review it?

> As per your patch, I wonder if a backwards scan would be faster.

I think so, thanks. I will resend it after netlink_forward_ring()
fix is applied.

Thanks,
Ken
