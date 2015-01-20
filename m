From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv4: Fix incorrect free in ICMP receive
Date: Tue, 20 Jan 2015 13:35:43 -0800
Message-ID: <1421789743.4832.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <05e337f44c7a71ac317194cfa3dcdf62.squirrel@www.codeaurora.org>
	 <1421412775.11734.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <ff3aa93b48dfedd7721d7fcc8ee7624b.squirrel@www.codeaurora.org>
	 <20150116.164830.172588830692811414.davem@davemloft.net>
	 <9dd57106ffab140ee31fb4f0390a87dd.squirrel@www.codeaurora.org>
	 <1421725837.17892.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7N-j5-iizM2pfjtAExn4Y3rq=UWGn1xyw8Z5OFO9u95ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:35332 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbATVfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:35:45 -0500
Received: by mail-ie0-f181.google.com with SMTP id rp18so7733iec.12
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 13:35:44 -0800 (PST)
In-Reply-To: <CAHA+R7N-j5-iizM2pfjtAExn4Y3rq=UWGn1xyw8Z5OFO9u95ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-20 at 11:42 -0800, Cong Wang wrote:

> 
> Or let the socket layer drop the packet instead of unconditionally
> dropping all icmp packets after success?

Sure, but that's probably at least 50 lines patch.

net-next candidate most likely.
