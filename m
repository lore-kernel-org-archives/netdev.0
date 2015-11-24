From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v3 2/2] net: add driver for Netronome
 NFP4000/NFP6000 NIC VFs
Date: Tue, 24 Nov 2015 19:53:05 +0000
Message-ID: <20151124195305.61524d83@jkicinski-Precision-T1700>
References: <20151030.192701.377276134095637949.davem@davemloft.net>
	<1448276697-2508-1-git-send-email-jakub.kicinski@netronome.com>
	<1448276697-2508-3-git-send-email-jakub.kicinski@netronome.com>
	<20151124.142531.1333743019199613941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35593 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753395AbbKXTxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 14:53:10 -0500
Received: by wmuu63 with SMTP id u63so111222555wmu.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 11:53:09 -0800 (PST)
In-Reply-To: <20151124.142531.1333743019199613941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Nov 2015 14:25:31 -0500 (EST), David Miller wrote:
> From: Jakub Kicinski <jakub.kicinski@netronome.com>
> Date: Mon, 23 Nov 2015 11:04:57 +0000
> 
> > +#ifdef CONFIG_NFP_NET_DEBUG
> > +#define DEBUG
> > +#endif
> 
> Do not design ad-hoc debug logging facilities locally in your driver,
> and instead use the existing tree wide facilities as they were designed
> to be used so that any user can get debugging logs simply by turning it
> on at run time rather than having the change magic config options in
> their kernel.

True.  I picked this habit up from the rt2x00 driver long time ago.
Now I see nobody else is doing such things...
