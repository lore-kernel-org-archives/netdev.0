From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:55:24 -0700 (PDT)
Message-ID: <20101026.105524.116376168.davem@davemloft.net>
References: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
	<20101026.104710.232747902.davem@davemloft.net>
	<AANLkTi=DPaxVLzasA_xs0rPQGBFtfbS7aThx54OT798H@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752045Ab0JZRzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:55:00 -0400
In-Reply-To: <AANLkTi=DPaxVLzasA_xs0rPQGBFtfbS7aThx54OT798H@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue, 26 Oct 2010 10:50:20 -0700

> On Tue, Oct 26, 2010 at 10:47 AM, David Miller <davem@davemloft.net> wrote:
>> Why would you do this when there are link layer indications that
>> we are attached to a different network?
> 
> Are there? For wifi you could look at the SSID (though even that is no

I'm saying to check the AP's MAC.
