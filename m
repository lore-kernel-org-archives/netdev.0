From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 7/9] wext: reduce inline abuse
Date: Thu, 26 Apr 2007 09:50:32 -0700
Message-ID: <20070426165032.GB22576@bougret.hpl.hp.com>
References: <20070424180732.371620000@sipsolutions.net> <20070424180849.651555000@sipsolutions.net>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:54194 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754845AbXDZQui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 12:50:38 -0400
Content-Disposition: inline
In-Reply-To: <20070424180849.651555000@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 08:07:39PM +0200, Johannes Berg wrote:
> This patch removes a bunch of inline abuse from wext. Most functions
> that were marked inline are only used once so the compiler will inline
> them anyway, others are used multiple times but there's no requirement
> for them to be inline since they aren't in any fast paths.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

	That's clearly not true of all compilers. All gcc versions
before 4.0 need serious help to inline functions used only once. Our
current minimal requirement for the kernel is gcc 3.2, therefore this
code is still useful.
	Note that this is a legitimate use of inline (tell the
compiler to inline the function), not an abuse.

	Jean
