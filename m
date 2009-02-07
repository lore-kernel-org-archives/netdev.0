From: David Miller <davem@davemloft.net>
Subject: Re: Soft lockup in sungem on Netra AC200 when switching interface
 up
Date: Fri, 06 Feb 2009 22:01:01 -0800 (PST)
Message-ID: <20090206.220101.239298299.davem@davemloft.net>
References: <20090206112902.GS4362@tango.lnet.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: itvirta@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbZBGGBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 01:01:05 -0500
In-Reply-To: <20090206112902.GS4362@tango.lnet.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilkka Virta <itvirta@iki.fi>
Date: Fri, 6 Feb 2009 13:29:02 +0200

> Looking at gem_do_start() and gem_open(), it seems that the only thing
> done while opening the device after the request_irq(), is a call to
> napi_enable().
> 
> I don't know what the ordering requirements are for the
> initialization, but I boldly tried to move the napi_enable() call
> inside gem_do_start() before the link state is checked and interrupts
> subsequently enabled, and it seems to work for me. Doesn't even break
> anything too obvious...
> 
> Any ideas on how this really should be fixed?

Actually your fix looks good, I'll apply this :-)

Thanks!
