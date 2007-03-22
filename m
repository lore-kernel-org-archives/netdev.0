From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] div64_64 optimization
Date: Thu, 22 Mar 2007 12:11:26 -0700 (PDT)
Message-ID: <20070322.121126.112613159.davem@davemloft.net>
References: <20070321115419.483a655a@freekitty>
	<20070321191537.GA28914@1wt.eu>
	<20070321131532.66e7f0e1@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965238AbXCVTL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:11:26 -0400
In-Reply-To: <20070321131532.66e7f0e1@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 21 Mar 2007 13:15:32 -0700

> Minor optimization of div64_64.  do_div() already does optimization
> for the case of 32 by 32 divide, so no need to do it here.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.22
