From: David Miller <davem@davemloft.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 13:27:56 -0700 (PDT)
Message-ID: <20091014.132756.231458769.davem@davemloft.net>
References: <a07586b0910141002m2a9f4466j412245fdae4e5372@mail.gmail.com>
	<20091014123328.1ebe35ea@s6510>
	<8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, brad.doctor@gmail.com,
	netdev@vger.kernel.org
To: deri@ntop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49616
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933895AbZJNU17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 16:27:59 -0400
In-Reply-To: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca Deri <deri@ntop.org>
Date: Wed, 14 Oct 2009 22:17:30 +0200

> Another reason, is that having a hook in dev.c, device drivers can
> pass PF_RING packets directly without going through the standard
> kernel mechanisms. For instance I have developed some drivers that if
> they detect the presence of PF_RING, pass received packets directly to
> PF_RING instead of going with NAPI.

There is absolutely no reason to do this.

If the existing infrastructure isn't good or fast enough,
fix it, don't bypass it.
