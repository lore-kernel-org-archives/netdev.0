From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: allow multiple dev per napi with GRO
Date: Thu, 02 Apr 2009 01:08:01 -0700 (PDT)
Message-ID: <20090402.010801.243630133.davem@davemloft.net>
References: <20090401142020.395f51bb@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33794
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753568AbZDBIIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:08:12 -0400
In-Reply-To: <20090401142020.395f51bb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 1 Apr 2009 14:20:20 -0700

> GRO assumes that there is a one-to-one relationship between NAPI
> structure and network device. Some devices like sky2 share multiple
> devices on a single interrupt so only have one NAPI handler. Rather than
> split GRO from NAPI, just have GRO assume if device changes that
> it is a different flow.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, applied.
