From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139cp: re-enable interrupts after tx timeout
Date: Sat, 24 Nov 2012 23:58:55 +0100
Message-ID: <20121124225855.GA17340@electric-eye.fr.zoreil.com>
References: <1353782365.26346.266.camel@shinybook.infradead.org>
 <20121124213348.GA8313@electric-eye.fr.zoreil.com>
 <1353795081.26346.287.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jasowang@redhat.com, gilboad@gmail.com,
	jgarzik@redhat.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45803 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab2KXXCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 18:02:22 -0500
Content-Disposition: inline
In-Reply-To: <1353795081.26346.287.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
> Recovery doesn't work too well if we leave interrupts disabled...
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

While you are at it, do you see what would prevent the watchdog
timer and the rx napi handler to race on two different CPUs
("using a Geode" could be an answer :o) ) ?

> ---
> For stable too, I suppose.

Yes. Watch for http://patchwork.ozlabs.org/bundle/davem/stable/

-- 
Ueimor
