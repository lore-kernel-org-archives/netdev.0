From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] enic: bug fix: return notify intr credits
Date: Mon, 09 Feb 2009 23:26:25 -0800 (PST)
Message-ID: <20090209.232625.30793494.davem@davemloft.net>
References: <20090210005505.24315.66810.stgit@palito_client100.nuovasystems.com>
	<20090210005711.24315.325.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbZBJH0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 02:26:32 -0500
In-Reply-To: <20090210005711.24315.325.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 09 Feb 2009 16:57:11 -0800

> enic: bug fix: return notify intr credits
>
> Return notify intr credits after notify intr from firmware.  This is
> especially important for legacy PCI intr mode, where not returning
> credits would cause PBA to remain asserted which would get us right
> back into the ISR.
>
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
