From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Fri, 04 May 2007 19:42:07 -0700 (PDT)
Message-ID: <20070504.194207.82054727.davem@davemloft.net>
References: <1178326521.4859.26.camel@dell>
	<463BD303.7000500@garzik.org>
	<1178329558.4859.38.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46418
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755437AbXEECmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 22:42:08 -0400
In-Reply-To: <1178329558.4859.38.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 18:45:58 -0700

> We had a discussion about 2 years ago and David decided to remove the
> I/O read to improve performance.  Since then a small number of users
> have been complaining about spurious interrupts.  We can add back the
> unconditional read or do this detection thing which I agree is somewhat
> annoying.  David, what do you think?

If we get an extra interrupt, we should just silently ignore it.

The performance impact of adding that thing back is just too great.

