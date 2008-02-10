From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix section mismatch warning for ISACVer
Date: Sat, 09 Feb 2008 23:29:41 -0800 (PST)
Message-ID: <20080209.232941.236153533.davem@davemloft.net>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
	<1202500804-32020-2-git-send-email-sam@ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, jgarzik@pobox.com
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758251AbYBJH3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:29:09 -0500
In-Reply-To: <1202500804-32020-2-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri,  8 Feb 2008 21:00:02 +0100

> Fix following warnings:
> WARNING: drivers/isdn/hisax/built-in.o(.text+0x19723): Section mismatch in reference from the function ISACVersion() to the variable .devinit.data:ISACVer
> WARNING: drivers/isdn/hisax/built-in.o(.text+0x2005b): Section mismatch in reference from the function setup_avm_a1_pcmcia() to the function .devinit.text:setup_isac()
> 
> ISACVer were only used from function annotated __devinit
> so add same annotation to ISACVer.
> One af the fererencing functions missed __devinit so add it
> and kill an additional warning.
> 
> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
> Acked-by: Karsten Keil <kkeil@suse.de>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: David Miller <davem@davemloft.net>

Also applied, thanks a lot Sam!
