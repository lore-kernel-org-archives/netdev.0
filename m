From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [patch 2.6.25-rc2-git] rndis_host:  fix transfer size
	negotiation
Date: Tue, 26 Feb 2008 08:51:27 +0200
Message-ID: <1204008687.10979.11.camel@localhost>
References: <200802221731.16698.david-b@pacbell.net>
	 <20080225182918.GA3094@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>,
	Network development list <netdev@vger.kernel.org>,
	Jean-Christophe Dubois <jcd@tribudubois.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:49751 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751655AbYBZGwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 01:52:34 -0500
In-Reply-To: <20080225182918.GA3094@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-25 at 13:29 -0500, John W. Linville wrote:
> On Fri, Feb 22, 2008 at 05:31:16PM -0800, David Brownell wrote:
> > From: Jean-Christophe Dubois <jcd@tribudubois.net>
> > 
> > This patch should resolve a problem that's troubled support for
> > some RNDIS peripherals.  It seems to have boiled down to using a
> > variable to establish transfer size limits before it was assigned,
> > which caused those devices to fallback to a default "jumbogram"
> > mode we don't support.  Fix by assigning it earlier for RNDIS.
> 
> Any chance that something like this is appropriate for rndis_wlan?
> 

This fix is automatically reflected to rndis_wlan since rndis_wlan
reuses that functions of that rndis_host module.

 - Jussi

