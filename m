From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: PATCH 2.6.24-rc3-mm2 - build breakage - bnx2x depends on
 ZLIB_INFLATE
Date: Thu, 29 Nov 2007 15:41:33 +0200
Message-ID: <1196343693.17721.47.camel@lb-tlvb-eliezer.il.broadcom.com>
References: <1196281524.5318.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>
To: "Lee Schermerhorn" <Lee.Schermerhorn@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3002 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756580AbXK2Nlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 08:41:55 -0500
In-Reply-To: <1196281524.5318.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-11-28 at 12:25 -0800, Lee Schermerhorn wrote:
> Couldn't find one of these on the lists...
> 
> PATCH 2.6.24-rc3-mm1:  bnx2x depends on ZLIB_INFLATE
> 
> The bnx2x module depends on the zlib_inflate functions.  The
> build will fail if ZLIB_INFLATE has not been selected manually
> or by building another module that automatically selects it.
> 
> Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
> and others.  This seems to fix it.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

You are right.
My mistake, Thanks.

Acked-by: Eliezer Tamir <eliezert@broadcom.com>


