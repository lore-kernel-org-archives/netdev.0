From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Increasing skb->mark size
Date: Wed, 2 Dec 2015 03:58:35 +0100
Message-ID: <20151202025835.GL15533@two.firstfloor.org>
References: <1448397144.14854.27.camel@mattb-dl>
 <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
 <87610ivv6u.fsf@tassilo.jf.intel.com>
 <565E1A9F.7040906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Lorenzo Colitti <lorenzo@google.com>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	davem@davemloft.net
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([193.170.194.197]:43935 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473AbbLBC6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 21:58:37 -0500
Content-Disposition: inline
In-Reply-To: <565E1A9F.7040906@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >This would be be great. I've recently ran into some issues with
> >the overhead of the Android firewall setup.
> >
> >So basically you need 4 extra bytes in sk_buff. How about:
> >
> >- shrinking skb->priority to 2 byte
> 
> That wouldn't work, see SO_PRIORITY and such (4 bytes) ...

But does anybody really use the full 4 bytes for the priority?
SO_PRIORITY could well truncate the value.

> 
> >- skb_iff is either skb->dev->iff or 0. so it could be replaced with a
> >single bit flag for the 0 case.
> 
> ... and that one wouldn't work on ingress.

Please explain.

-Andi
