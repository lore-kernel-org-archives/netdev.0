From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sleeping in irq context in match()
Date: Wed, 23 Jul 2008 20:14:44 +0100
Message-ID: <20080723191443.GT10471@solarflare.com>
References: <20080723115706.38060204@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Davis <alex14641@yahoo.com>, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:58348 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752649AbYGWTOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 15:14:51 -0400
Content-Disposition: inline
In-Reply-To: <20080723115706.38060204@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> Hi,
> 
> the backtrace below is popping up in kerneloops.org stats pretty
> quickly; I don't know if it's been discussed here before but
> just wanted to mention it in case it hasn't been..
> (it's rank 13 right now, out of nowhere)
> 
> http://www.kerneloops.org/searchweek.php?search=match  for more info
> 
> 
> __might_sleep
> mutex_lock_nested
> rtnl_lock
> *match
[...]

Looking at the "more info", I see that that function is in xt_ipisforif,
which is an out-of-tree module.  The author appears to be
Alex Davis <alex14641@yahoo.com>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
