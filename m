From: David Miller <davem@davemloft.net>
Subject: Re: [patch resend build-breakage] make bnx2x select ZLIB_INFLATE
Date: Wed, 05 Dec 2007 06:16:57 -0800 (PST)
Message-ID: <20071205.061657.257368400.davem@davemloft.net>
References: <1196863959.5204.25.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, Lee.Schermerhorn@hp.com
To: eliezert@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47313
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751850AbXLEOQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 09:16:58 -0500
In-Reply-To: <1196863959.5204.25.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eliezer Tamir" <eliezert@broadcom.com>
Date: Wed, 05 Dec 2007 16:12:39 +0200

> The bnx2x module depends on the zlib_inflate functions.  The
> build will fail if ZLIB_INFLATE has not been selected manually
> or by building another module that automatically selects it.
> 
> Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
> and others.  This seems to fix it.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: Eliezer Tamir <eliezert@broadcom.com>

Looks better, Jeff please suck this in.

