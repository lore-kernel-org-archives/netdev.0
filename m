From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC limit sk_mem_quantum to 8192
Date: Tue, 21 May 2013 19:21:01 -0700
Message-ID: <1369189261.3301.269.camel@edumazet-glaptop>
References: <20130522004541.GA17240@obelix.rh>
	 <1369184962.3301.264.camel@edumazet-glaptop>
	 <20130522015858.GB17240@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:53807 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753617Ab3EVCVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 22:21:04 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq12so1315829pab.12
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 19:21:03 -0700 (PDT)
In-Reply-To: <20130522015858.GB17240@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 22:58 -0300, Flavio Leitner wrote:
> On Tue, May 21, 2013 at 06:09:22PM -0700, Eric Dumazet wrote:
>  
> > Are you sure a network driver doesn't provide skb using a full page ?
> 
> You lost me. You're saying that today we consider a page size
> a minimum and so if we reduce that, the skb wouldn't fit in the
> min sk memory?

SK_MEM_QUANTUM is also used in UDP stack, thats why I am asking.
