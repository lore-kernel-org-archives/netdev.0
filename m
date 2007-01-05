From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Thu, 04 Jan 2007 21:42:04 -0800 (PST)
Message-ID: <20070104.214204.55835976.davem@davemloft.net>
References: <20070104200437.008980288@hp.com>
	<20070104.165735.102614518.davem@davemloft.net>
	<39e6f6c70701041832u6e1d8c86w4728ac605f7449e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48659
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030341AbXAEFmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 00:42:07 -0500
To: arnaldo.melo@gmail.com
In-Reply-To: <39e6f6c70701041832u6e1d8c86w4728ac605f7449e3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 5 Jan 2007 00:32:31 -0200

> I expected a warning since the and operation clearly could yield a
> value that would overflow, just like in the constant case...

It sounds stupid, but once you introduce variables and not
everything is constance, GCC currently can't make the analysis.

It's an interesting class of bugs to detect automatically, for
sure :-)
