From: Steve.Glendinning@smsc.com
Subject: Re: smsc911x suspend/resume
Date: Mon, 8 Feb 2010 12:27:50 +0000
Message-ID: <OFF34C9E86.0CCFA0E8-ON802576C4.0041FE48-802576C4.00447BBD@smsc.com>
References: <20100208115316.GA28972@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Ian.Saturley@smsc.com,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	Mike Rapoport <mike@compulab.co.il>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Vlad.Lyalikov@smsc.com
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:57377 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750780Ab0BHM2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 07:28:12 -0500
In-Reply-To: <20100208115316.GA28972@buzzloop.caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I don't have the code in front of me (I'm travelling today) but IIRC
> > the driver doesn't place the LAN9220 in a specific power saving state,
> > so as far as the LAN9220 is concerned it's not actually suspended.
> 
> It does, I added that awhile back in b6907b0c7. But as I say, this is
> currently hard-coded to D1, and if support for D2 is desired, we would
> need to make that a platform data option.

You're right, and I should remember as I reviewed it!

Steve
