From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc91x: fix unused flags warnings on UP systems
Date: Fri, 11 Dec 2009 15:15:02 -0800 (PST)
Message-ID: <20091211.151502.188418417.davem@davemloft.net>
References: <1260366004-27366-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@fluxnic.net,
	linux-kernel@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58929
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbZLKXO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:14:56 -0500
In-Reply-To: <1260366004-27366-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed,  9 Dec 2009 08:40:04 -0500

> Local flags variables will be declared whenever these functions get used,
> but obviously on UP systems the flags parameter won't be touched.  So add
> some dummy ops that get optimized away anyways to satisfy gcc's warnings.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

Applied, although I thought we had a standard macro to handle this
kind of case.

In any case, for future reference, the usual way to handle this is
usually "(void) var;"
