From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Who's allowed to set a skb destructor?
Date: Thu, 5 Jul 2007 14:28:50 +0200
Message-ID: <20070705122849.GA4759@ff.dom.local>
References: <p733b032mec.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <Brice.Goglin@ens-lyon.org>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Divy Le Ray <divy@chelsio.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:46485 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754331AbXGEMUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 08:20:22 -0400
Content-Disposition: inline
In-Reply-To: <p733b032mec.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05-07-2007 12:08, Andi Kleen wrote:
...
> The traditional standpoint was that having your own large skb pools 
> is not recommended because you won't interact well with the 
> rest of the system running low on memory and you tieing up 
> memory.
> 
> Essentially you would recreate all the problems traditional Unix
> systems have with fixed size mbuf pools. Linux always used a more
> dynamic and flexible allocate-only-as-you-need approach even when it
> can have a little more overhead in managing IOMMUs etc.

I wonder if it's very unsound to think about a one way list
of destructors. Of course, not owners could only clean their
private allocations. Woudn't this save some skb clonning,
copying or adding new fields for private infos?

Regards,
Jarek P.
