From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 11:19:56 -0700
Message-ID: <1413569996.25949.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Od13Bnn3wciLNrA-RsYuYBAjvwAzc20dgGtYT_=EX88w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33696 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbaJQST5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 14:19:57 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so1274206pab.18
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 11:19:57 -0700 (PDT)
In-Reply-To: <CAHA+R7Od13Bnn3wciLNrA-RsYuYBAjvwAzc20dgGtYT_=EX88w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 09:58 -0700, Cong Wang wrote:

> I doubt we still need to store iif in IP6CB() since we have skb->skb_iif,
> we can probably just make inet6_iif() be like inet_iif() so that IP6CB()->iif
> can be just removed? Does this make any sense to you?
> 

This makes sense and would gain 4 bytes in skb->cb[], so definitely
worth it.

> (I have a patch locally since I thought it should be target for net-next.)
> 
