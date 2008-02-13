From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETLABEL]: Fix lookup logic of
 netlbl_domhsh_search_def.
Date: Tue, 12 Feb 2008 22:15:41 -0800 (PST)
Message-ID: <20080212.221541.57781950.davem@davemloft.net>
References: <47B1C8E4.6010908@openvz.org>
	<200802121134.09965.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750981AbYBMGPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 01:15:09 -0500
In-Reply-To: <200802121134.09965.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 12 Feb 2008 11:34:09 -0500

> On Tuesday 12 February 2008 11:27:16 am Pavel Emelyanov wrote:
> > Currently, if the call to netlbl_domhsh_search succeeds the
> > return result will still be NULL.
> >
> > Fix that, by returning the found entry (if any).
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Good catch, thanks.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied, thanks everyone.
