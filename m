From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for fragmentation support
Date: Thu, 20 Oct 2011 17:13:27 +0400
Message-ID: <4EA01E77.8040300@gmail.com>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net> <1319114385.3781.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CAJmB2rCe3BJKD07TOSyAT0vbDq_K1VHLOtECqeOMzaTsg3DokA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	slapin@ossfans.org, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jonsmirl@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38194 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab1JTNO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 09:14:57 -0400
Received: by wwe6 with SMTP id 6so4151467wwe.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 06:14:56 -0700 (PDT)
In-Reply-To: <CAJmB2rCe3BJKD07TOSyAT0vbDq_K1VHLOtECqeOMzaTsg3DokA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Alexander, colleagues,

On 10/20/2011 04:50 PM, Alexander Smirnov wrote:
> Hi Eric,
>
> thank you for the replies. And another question I forgot to ask:
>
> when I send fragments, I still have original skb buffer. What should I
> do with it, is there any
> "proper/good" ways to drop it? Because I've already fragmented it and
> do not need to send
> original skb to queue.

You might want to check the TCP/IP fragmentation code path. I think you 
can drop it with kfree_skb, but I ain't sure ATM.

>
> Thank you,
> Alexander

P.S. Top posting is really a bad style. And it's now that welcome in the 
MLs.

-- 
With best wishes
Dmitry
