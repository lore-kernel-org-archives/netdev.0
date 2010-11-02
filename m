From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Mon, 01 Nov 2010 21:50:27 -0500
Message-ID: <1288666227.4003.43.camel@dcbw.foobar.com>
References: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
	 <20101026.104710.232747902.davem@davemloft.net>
	 <AANLkTi=DPaxVLzasA_xs0rPQGBFtfbS7aThx54OT798H@mail.gmail.com>
	 <20101026.105524.116376168.davem@davemloft.net>
	 <AANLkTi=Wp83HtQHXG0YEBjmctQYDu9Y4j+O9==_URy_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083Ab0KBCwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 22:52:47 -0400
In-Reply-To: <AANLkTi=Wp83HtQHXG0YEBjmctQYDu9Y4j+O9==_URy_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-10-26 at 11:02 -0700, Lorenzo Colitti wrote:
> On Tue, Oct 26, 2010 at 10:55 AM, David Miller <davem@davemloft.net> wrote:
> >> Are there? For wifi you could look at the SSID (though even that is no
> >
> > I'm saying to check the AP's MAC.
> 
> Ah yes, that works better. But for wired? Or do you think it should be
> fixed only for wifi?

Only looking at the SSID tells you if you're on a different network.
Just looking at the AP MAC is like plugging into a different port on the
same switch: it's still the same network.

Dan


