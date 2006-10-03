From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Tue, 3 Oct 2006 11:35:38 -0700
Message-ID: <20061003113538.4c3fe57d@freekitty>
References: <20060922112442.GB4161@dezo.moloch.sk>
	<20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
	<20060922182924.GE4161@dezo.moloch.sk>
	<20060922113152.02874cbc@localhost.localdomain>
	<20060922183812.GF4161@dezo.moloch.sk>
	<20060922115008.5060c599@localhost.localdomain>
	<20061003182119.GM14180@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59806 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030466AbWJCSgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2006 14:36:00 -0400
To: Martin Lucina <mato@kotelna.sk>
In-Reply-To: <20061003182119.GM14180@dezo.moloch.sk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006 20:21:20 +0200
Martin Lucina <mato@kotelna.sk> wrote:

> Hi Stephen,
> 
> I'm still getting tx timeouts even after applying the patch you sent me
> and forcing tx flow control off:

What speed and duplex are you using?

> 
> Also, I'm seeing a bunch of messages like this (in addition to the hw
> csum failures I mentioned in my original email):
> 
> Oct  2 16:42:17 dezo kernel: SKB BUG: Invalid truesize (3944) len=12745, sizeof(sk_buff)=2
> 32
> Oct  2 16:42:29 dezo kernel: SKB BUG: Invalid truesize (3944) len=16384, sizeof(sk_buff)=2
> 32
> Oct  2 16:42:29 dezo last message repeated 11 times
> Oct  3 17:20:54 dezo kernel: SKB BUG: Invalid truesize (3944) len=16384, sizeof(sk_buff)=2
> 32
> Oct  3 17:21:56 dezo last message repeated 4 times
> Oct  3 17:21:56 dezo last message repeated 3 times
> Oct  3 17:23:46 dezo last message repeated 2 times
> Oct  3 20:03:28 dezo kernel: SKB BUG: Invalid truesize (3944) len=16384, sizeof(sk_buff)=2
> 32
> Oct  3 20:03:28 dezo last message repeated 16 times
> 
> After which some open TCP sockets between dezo and another box (also
> with sky2) start running really slowly.

What MTU are you using.

> 
> Not sure how to proceed with this - is there a newer version of sky2
> than that in 2.6.18 which I can test?
> 
> -mato


-- 
Stephen Hemminger <shemminger@osdl.org>
