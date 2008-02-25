From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.25-rc2-git] rndis_host:  fix transfer size
	negotiation
Date: Mon, 25 Feb 2008 13:29:18 -0500
Message-ID: <20080225182918.GA3094@tuxdriver.com>
References: <200802221731.16698.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network development list <netdev@vger.kernel.org>,
	Jean-Christophe Dubois <jcd@tribudubois.net>,
	jussi.kivilinna@mbnet.fi
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4369 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757975AbYBYScT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 13:32:19 -0500
Content-Disposition: inline
In-Reply-To: <200802221731.16698.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 22, 2008 at 05:31:16PM -0800, David Brownell wrote:
> From: Jean-Christophe Dubois <jcd@tribudubois.net>
> 
> This patch should resolve a problem that's troubled support for
> some RNDIS peripherals.  It seems to have boiled down to using a
> variable to establish transfer size limits before it was assigned,
> which caused those devices to fallback to a default "jumbogram"
> mode we don't support.  Fix by assigning it earlier for RNDIS.

Any chance that something like this is appropriate for rndis_wlan?

John
-- 
John W. Linville
linville@tuxdriver.com
