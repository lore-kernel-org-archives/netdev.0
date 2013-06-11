From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Tue, 11 Jun 2013 01:16:15 -0700 (PDT)
Message-ID: <20130611.011615.941255845283559918.davem@davemloft.net>
References: <20130605094111.GB2522@raven>
	<1370437077.4021.15.camel@deadeye.wl.decadent.org.uk>
	<20130611080038.GA2496@raven>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	jchapman@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab3FKIQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 04:16:16 -0400
In-Reply-To: <20130611080038.GA2496@raven>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Tue, 11 Jun 2013 09:00:38 +0100

> Dave -- could you give me a steer?  Are you happy to keep this kind of
> calculation in the transport layer, or should I look to push something
> generic into the IP code?

I think it's an IP layer issue, so should be handled there.

Thanks.
