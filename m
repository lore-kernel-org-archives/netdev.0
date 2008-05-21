From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for
 linklocal is completed.
Date: Wed, 21 May 2008 13:30:38 -0700 (PDT)
Message-ID: <20080521.133038.76262737.davem@davemloft.net>
References: <4832C3CC.5070609@miraclelinux.com>
	<20080522.015807.02348209.yoshfuji@linux-ipv6.org>
	<48345C4C.6020106@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: tabe@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35587
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755543AbYEUUan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 16:30:43 -0400
In-Reply-To: <48345C4C.6020106@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toyo Abe <tabe@miraclelinux.com>
Date: Thu, 22 May 2008 02:30:52 +0900

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <4832C3CC.5070609@miraclelinux.com> (at Tue, 20 May 2008 21:27:56 +0900), Toyo Abe <tabe@miraclelinux.com> says:
> >> Since current addrconf code actually accepts RA including prefix option 
> >> while DAD for
> >> linklocal address is processing, changes of the behaviour looks like a 
> >> degradation for me.
> >> Hence, I chose to accept RA at that moment and defer sending DAD NS for 
> >> global addresses.
> > 
> > Well I don't think so.
> > We should choose simpler way - avoid introducing new "unique" state so far.
> > 
> > If you really think is worth accepting RA during DAD for link-local
> > address, we should cancel all of on-going DADs for global address(es)
> > if the RA for link-local address has failed, intead of deferring DAD
> > for global address(es).
> >
> You're right. I agree with you that it'd be better than mine.

Hideaki-san, let me know if I should apply your patch.

Thank you.
