From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Ignore route option with
 ROUTER_PREF_INVALID
Date: Wed, 16 Sep 2009 17:12:56 -0700 (PDT)
Message-ID: <20090916.171256.218164875.davem@davemloft.net>
References: <1252599911.5980.16.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: me@jayr.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998AbZIQAMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 20:12:39 -0400
In-Reply-To: <1252599911.5980.16.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jens Rosenboom <me@jayr.de>
Date: Thu, 10 Sep 2009 18:25:11 +0200

> RFC4191 says that "If the Reserved (10) value is received, the Route
> Information Option MUST be ignored.", so this patch makes us conform
> to the RFC. This is different to the usage of the Default Router
> Preference, where an invalid value must indeed be treated as
> PREF_MEDIUM.
> 
> Signed-off-by: Jens Rosenboom <me@jayr.de>

Applied, thanks Jens.
