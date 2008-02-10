From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix section mismatch warnings in isac.c and
 isar.c
Date: Sat, 09 Feb 2008 23:28:25 -0800 (PST)
Message-ID: <20080209.232825.169192396.davem@davemloft.net>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
	<1202500804-32020-3-git-send-email-sam@ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, jgarzik@pobox.com
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33593
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760114AbYBJH1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:27:54 -0500
In-Reply-To: <1202500804-32020-3-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri,  8 Feb 2008 21:00:03 +0100

> Fix the following warnings:
 ...
> 
> initisar(), initisac() and clear_pending_isac_ints()
> were all used via a cardmsg fnction - which may be called
> ouside __devinit context.
> So remove the bogus __devinit annotation of the
> above three functions to fix the warnings.
> 
> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
> Acked-by: Karsten Keil <kkeil@suse.de>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: David Miller <davem@davemloft.net>

Applied.
