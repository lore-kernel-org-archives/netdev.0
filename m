From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV4] annotate a few functions __init in ipconfig.c
Date: Tue, 29 Apr 2008 20:58:29 -0700 (PDT)
Message-ID: <20080429.205829.125946358.davem@davemloft.net>
References: <20080429195006.GA468@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751582AbYD3D6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 23:58:30 -0400
In-Reply-To: <20080429195006.GA468@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Tue, 29 Apr 2008 21:50:06 +0200

> A few functions are only used from __init context.
> So annotate these with __init for consistency and silence
> the following warnings:
> 
> WARNING: net/ipv4/built-in.o(.text+0x2a876): Section mismatch
>          in reference from the function ic_bootp_init() to
>          the variable .init.data:bootp_packet_type
> WARNING: net/ipv4/built-in.o(.text+0x2a907): Section mismatch
>          in reference from the function ic_bootp_cleanup() to
>          the variable .init.data:bootp_packet_type
> 
> Note: The warnings only appear with CONFIG_DEBUG_SECTION_MISMATCH=y
> 
> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>

Applied, thanks a lot Sam.
