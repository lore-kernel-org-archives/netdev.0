From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH for [Bug 8952] tulip driver oops in tulip_interrupt when
 hibernating with swsusp/suspend2
Date: Fri, 30 May 2008 22:12:17 -0400
Message-ID: <4840B401.4020402@pobox.com>
References: <20080512063751.GH32317@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37069 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYEaCMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:12:19 -0400
In-Reply-To: <20080512063751.GH32317@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> Jeff,
> The following patch is seems to fix the tulip suspend/resume panic:
> 	http://bugzilla.kernel.org/show_bug.cgi?id=8952#c46
> 
> My attempts at a cleaner patch failed and Pavel thinks this is OK.
> Since suspend/resume is getting an overhaul in 2.6.27 (per comment
> #49 by  Rafael J. Wysocki), it makes sense to invest more time as
> part of that rework and apply the known fix to 2.6.26.
> 
> hth,
> grant
> 
> Original from:  kernelbugs@tap.homeip.net
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> 
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c

applied


