From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net: fix /proc/net/dev regression
Date: Tue, 03 Apr 2012 17:59:06 +0200
Message-ID: <1333468746.18626.276.camel@edumazet-glaptop>
References: <4F7A7C98.1030103@candelatech.com>
	 <1333431810.18626.37.camel@edumazet-glaptop>
	 <4F7A905B.3080107@candelatech.com>
	 <1333434995.18626.39.camel@edumazet-glaptop>
	 <1333436789.18626.43.camel@edumazet-glaptop>
	 <1333441982.18626.62.camel@edumazet-glaptop>
	 <4F7B1910.3010701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:48031 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754823Ab2DCP7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 11:59:11 -0400
Received: by wibhj6 with SMTP id hj6so3803076wib.1
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 08:59:09 -0700 (PDT)
In-Reply-To: <4F7B1910.3010701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 08:36 -0700, Ben Greear wrote:

> 
> This appears to fix the problem.  I do find it mildly irritating
> that the ordering is now random in /proc/net/dev, but I guess
> that is the price of progress.
> 

Well, as new devices are inserted at front of each hash list, this was
already the case before Mihai work.

By the way, ifconfig does a sort before output.

> Tested-by:  Ben Greear <greearb@candelatech.com>

Thanks !
