From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH] net-ipv4-tcp.c-fix-warning-from-older-compilers.patch
Date: Fri, 11 Dec 2009 10:30:24 -0500
Message-ID: <4B226590.6030608@gmail.com>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>	 <4B1F0151.10903@gmail.com>	 <20091208180801.88be28ba.akpm@linux-foundation.org>	 <4B20FC2E.7050809@gmail.com>  <4B2102B4.7050702@gmail.com> <1260455516.2783.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:33130 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758635AbZLKPgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 10:36:53 -0500
Received: by yxe17 with SMTP id 17so869652yxe.33
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2009 07:37:00 -0800 (PST)
In-Reply-To: <1260455516.2783.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> You can use BUILD_BUG_ON() to ensure that remains true.
> 
Another fine undocumented Linux Kernel feature.  In the absence of
standardized functions that check for buffer overruns, that's just
the ticket!

Kinda the opposite conditional of static assert, but I'm pretty sure
static assert wasn't working in gcc until a year or so ago.  That's
why I used the more old-fashioned test instead.  I'd no idea those
triggered a warning in some versions of gcc -- I never trusted 4.0.x,
and had plenty of problems with 4.1.x, too.

Thanks, I'll resubmit.
