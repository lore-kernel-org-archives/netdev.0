From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: More details on why received UDP packets are treated as errors?
Date: Mon, 29 Jul 2013 13:21:32 -0700
Message-ID: <1375129292.10515.21.camel@edumazet-glaptop>
References: <51F6B2AB.5050607@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37295 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab3G2UVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 16:21:34 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so1361744pbb.5
        for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 13:21:33 -0700 (PDT)
In-Reply-To: <51F6B2AB.5050607@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-29 at 11:21 -0700, Ben Greear wrote:
> We have a test case on 3.9.9+ (local patches applied) where sending from
> VETH interface, through peer VETH bridged (with our own emulator bridge module)
> to physical interface, which is then looped to another physical interface (B).
> The VETH and the wired B interface are sending UDP traffic to each other.
> Routing rules should be configured such that this all works appropriately.
> 
> Replacing our bridging module with a user-space bridge has same behaviour.
> 
> This setup works on the 3.7.y kernel, but we only get one-way traffic
> (B to VETH) on 3.9.9+.
> 
> I sniffed the B port, and traffic appears to be sent and received
> properly (ie, no checksum errors, etc).  But, our user-space app
> shows no received UDP frames on B, and netstat -s gives the
> output below.
> 
> Is there any way to get more details about what these 'packet receive errors'
> are caused by using normal-ish tools?

You could try dropwatch for this kind of obscure drops

https://fedorahosted.org/dropwatch/
