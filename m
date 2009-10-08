From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 0/5] IPsec: convert to ahash
Date: Thu, 8 Oct 2009 10:46:31 +0200
Message-ID: <20091008084631.GJ15653@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:43746 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbZJHIrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 04:47:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset converts the authentication header (ah4/ah6) IPsec protocol
over to the new ahash interface. With this patchset IPsec is completely
converted to ahash. The esp protocol is already converted to ahash by
converting the authenc crypto algorithm.

Steffen
