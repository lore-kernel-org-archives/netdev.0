From: David Miller <davem@davemloft.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Tue, 04 Nov 2008 21:58:39 -0800 (PST)
Message-ID: <20081104.215839.132524253.davem@davemloft.net>
References: <49107543.5080207@blueteddy.net>
	<20081104.145242.112948002.davem@davemloft.net>
	<1225847763.11369.43.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@blueteddy.net, daniel.blueman@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44018
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750743AbYKEF7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 00:59:06 -0500
In-Reply-To: <1225847763.11369.43.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 04 Nov 2008 17:16:03 -0800

> I think this is no longer a limitation.  The GSO code will take care
> of ECN properly if the hardware does not support it when doing TSO.

Hmm, good point, but if that is what happens I don't know if I agree
with it.

If "take care of ECN" means doing TSO in software, that's in my
opinion the wrong thing to do.
