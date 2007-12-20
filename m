From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Thu, 20 Dec 2007 03:22:28 -0800 (PST)
Message-ID: <20071220.032228.186653113.davem@davemloft.net>
References: <47601A73.5010804@myri.com>
	<20071212.093819.205755031.davem@davemloft.net>
	<18282.15185.592112.550961@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org
To: Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754402AbXLTLW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 06:22:29 -0500
In-Reply-To: <18282.15185.592112.550961@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Thu, 20 Dec 2007 10:52:17 +0100

>  Yes but the reason was not to wait for all pending polls to
>  complete so a server/router could be rebooted even under high-
>  load and DOS. We've experienced some nasty problems with this.

I know, see the rest of the thread where I agree that
we need to deal with this somehow.

The device is marked down first, and somehow we need to
tip off of that to break out of the NAPI loop.  This
"how" is what hasn't been resolved yet.
