From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix section mismatch warning in hfc_sx.c
Date: Sat, 09 Feb 2008 23:27:50 -0800 (PST)
Message-ID: <20080209.232750.94719107.davem@davemloft.net>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
	<1202500804-32020-4-git-send-email-sam@ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, jgarzik@pobox.com
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759935AbYBJH1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:27:19 -0500
In-Reply-To: <1202500804-32020-4-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri,  8 Feb 2008 21:00:04 +0100

> Fix the following warning:
> WARNING: drivers/isdn/hisax/built-in.o(.text+0x35818): Section mismatch in reference from the function hfcsx_card_msg() to the function .devinit.text:inithfcsx()
> 
> hfcsx_card_msg() may be called outside __devinit context.
> Following the program logic is looks like the CARD_INIT branch
> will only be taken under __devinit context but to be consistent
> remove the __devinit annotation of inithfcsx() so we
> do not mix non-__devinit and __devinit code.
> 
> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
> Acked-by: Karsten Keil <kkeil@suse.de>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: David Miller <davem@davemloft.net>

Applied.
