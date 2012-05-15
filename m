From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 15 May 2012 18:34:01 +0200
Message-ID: <1337099641.8512.1102.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37012 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965807Ab2EOQeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 12:34:06 -0400
Received: by bkcji2 with SMTP id ji2so4989747bkc.19
        for <netdev@vger.kernel.org>; Tue, 15 May 2012 09:34:05 -0700 (PDT)
In-Reply-To: <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-15 at 17:29 +0100, Kieran Mansley wrote:
> On Tue, 2012-05-15 at 16:56 +0200, Eric Dumazet wrote:
> > 
> > Please try latest kernels, this is probably 'fixed'
> 
> I've just tried with 3.4.0-rc7 and the problem is still reproducible.
> It's perhaps harder to reproduce than on 3.3.6 but still there.
> 
> > What network driver are you using ? 
> 
> The receiver is using the sfc driver that is included in the kernel
> build, together with an SFC 9020 NIC. 
> 
> Kieran
> 

MTU ?

What is typical skb->truesize of skb given to stack in RX path ?

If drivers use PAGE_SIZE fragments, then you are more likely to hit
limit.
