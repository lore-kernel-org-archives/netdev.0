From: David Miller <davem@davemloft.net>
Subject: Re: ProxyARP and IPSec
Date: Fri, 22 Sep 2006 13:36:46 -0700 (PDT)
Message-ID: <20060922.133646.68153303.davem@davemloft.net>
References: <20060904222722.GA24078@ms2.inr.ac.ru>
	<44FD0759.8070307@zytor.com>
	<20060905090530.GA17104@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, stephen@dino.dnsalias.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54165
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964899AbWIVUg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 16:36:29 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060905090530.GA17104@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Tue, 5 Sep 2006 13:05:30 +0400

> Look into old rfc2401, search for word "fragment".
> Then search for the same word in new rfc4301. All those 100K of new text
> deal with various design bugs in IPsec, mostly with pathologies encountered
> in the case of security gateways. (Some section there are real fun: f.e.
> look at section 7.2)

I even was not aware of this problem. :-)

Essentially, if you use ports as part of your selector,
then it is impossible to handle anything other than the
first fragment of a fragmented frame because the subsequent
fragments will not have the ports which you need in order
to match.

The suggestions in 7.2 involving a seperate SA for the non-first
fragments seem totally unrealistic, if you ask me.  They even say
the idea cannot work with ipv6, what is the point? :-)


