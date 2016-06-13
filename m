From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] IPsec NAT-T issue
Date: Mon, 13 Jun 2016 12:20:24 +0200
Message-ID: <20160613102024.GX7698@gauss.secunet.com>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Blair Steven <blair.steven@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:46145 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964910AbcFMKqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 06:46:42 -0400
Content-Disposition: inline
In-Reply-To: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 11:48:13AM +1200, Blair Steven wrote:
> 
> During testing we have discovered an issue with IPsec NAT-T where the SPI
> is over writing the source and dest ports of the UDP header. 

The headers should be restored after the crypto operation in
esp_restore_header(). Does this not happen in your case? What
kind of problem do you experience?
