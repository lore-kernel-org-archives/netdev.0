From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix section mismatch warnings from
 hisax_cs_setup_card
Date: Sat, 09 Feb 2008 23:29:04 -0800 (PST)
Message-ID: <20080209.232904.166015345.davem@davemloft.net>
References: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, jgarzik@pobox.com
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58431
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756265AbYBJH2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:28:33 -0500
In-Reply-To: <1202500804-32020-1-git-send-email-sam@ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri,  8 Feb 2008 21:00:01 +0100

> Fix the following warnings:
 ...
> 
> checkcard() are the only user of hisax_cs_setup_card().
> And checkcard is only used during init or when hot plugging
> ISDN devices. So annotate hisax_cs_setup_card() with __devinit.
> checkcard() is used by exported functions so it cannot be
> annotated __devinit. Annotate it with __ref so modpost
> ignore references to _devinit section.
> 
> Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
> Acked-by: Karsten Keil <kkeil@suse.de>
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Cc: David Miller <davem@davemloft.net>

Applied.
