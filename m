From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis190: use an adequate phy list entry as a fallback
Date: Wed, 17 Jun 2009 18:54:03 -0700 (PDT)
Message-ID: <20090617.185403.24239452.davem@davemloft.net>
References: <20090617214311.GB27064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: apatard@mandriva.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51096
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752708AbZFRByA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:54:00 -0400
In-Reply-To: <20090617214311.GB27064@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 17 Jun 2009 23:43:11 +0200

> When sis190 driver is trying to get default phy, if it doesn't find home
> or lan phy, it falls back to the first phy in the phy list but list_entry()
> points to a bogus entry. list_first_entry() should be used instead.
> 
> Signed-off-by: Arnaud Patard <apatard@mandriva.com>
> Acked-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
