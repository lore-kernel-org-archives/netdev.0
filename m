From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.9.5+:  Crash in tcp_input.c:4810.
Date: Tue, 02 Jul 2013 21:41:52 -0700
Message-ID: <1372826512.4979.49.camel@edumazet-glaptop>
References: <51BF50B3.1080403@candelatech.com>
	  <1371493059.3252.200.camel@edumazet-glaptop>
	  <51D1C620.8030007@candelatech.com>
	 <1372813467.4979.46.camel@edumazet-glaptop>
	 <51D398C0.5060802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:59467 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab3GCEly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 00:41:54 -0400
Received: by mail-pa0-f53.google.com with SMTP id tj12so7104655pac.12
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 21:41:54 -0700 (PDT)
In-Reply-To: <51D398C0.5060802@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-02 at 20:21 -0700, Ben Greear wrote:

> What kinds of things could a driver do to cause this.  Maybe modify an
> skb after it has sent it up the stack, or something like that?
> 

It might be a genuine TCP bug, who knows...


> We haven't been able to reproduce on a clean 3.10 yet...but it often takes days,
> so we'll leave the test up through end of this week if we don't hit it
> sooner...

TCP collapse is/should be really rare, but losses can of course trigger
it.

> 
> I'll add your patch to my 3.9 tree.

Thanks
