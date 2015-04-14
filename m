From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp/dccp: get rid of central timewait timer
Date: Mon, 13 Apr 2015 19:47:21 -0700
Message-ID: <1428979641.7346.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428693574.25985.326.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1428889869.25985.375.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150413.164050.281703475037013729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37784 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbbDNCrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 22:47:24 -0400
Received: by igblo3 with SMTP id lo3so4700525igb.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 19:47:23 -0700 (PDT)
In-Reply-To: <20150413.164050.281703475037013729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-13 at 16:40 -0400, David Miller wrote:

> Applied, but:
> 

> > +	tw->tw_kill = timeo <= 4*HZ;	
> 
> That last line has trailing whitespace which I removed.

Sure, thanks for taking care of this David.
