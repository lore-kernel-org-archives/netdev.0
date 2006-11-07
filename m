From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Fixed a number of bugs in the PHY Layer
Date: Tue, 07 Nov 2006 04:39:10 -0500
Message-ID: <4550543E.2090703@pobox.com>
References: <Pine.LNX.4.61.0610161603370.6266@ld0175-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:2484 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1754156AbWKGJjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 04:39:13 -0500
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <Pine.LNX.4.61.0610161603370.6266@ld0175-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Fleming wrote:
> * genphy_update_link is now exported
> * Added a fix from ncase@xes-inc.com which changes forcing so it
>   only updates the link.  Otherwise, it never tries the lower
>   values, since it is always overwriting the speed/duplex values
>   with the current ones, rather than the intended ones.
> * Fixed a bug where bringing up a PHY with no link caused it to
>   timeout, and enter forcing mode.  Once in forcing mode,
>   plugging in the link didn't autonegotiate.  Now the AN state
>   detects the lack of link, and enters the NO_LINK state.  AN
>   only times out if the link is up and AN fails
> * Cleaned up the PHY_AN case, reducing one level of indentation
>   for the timeout code.

applied

Please include a Signed-off-by line in future patches!

	Jeff



