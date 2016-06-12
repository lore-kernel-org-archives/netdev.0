From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Macro definition for SFF-8436/8636
 Memory map max sizes
Date: Sat, 11 Jun 2016 19:26:48 -0700 (PDT)
Message-ID: <20160611.192648.91885921700006865.davem@davemloft.net>
References: <1465278926-10231-1-git-send-email-vidya@cumulusnetworks.com>
	<20160611.155134.1474324006340328110.davem@davemloft.net>
	<CAKWE-Xrw6kE7-rSOP1NRQaT3jAHWVVkhWz8c2oinYmQc+LrnjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bwh@kernel.org, netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: vidya@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbcFLC0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 22:26:51 -0400
In-Reply-To: <CAKWE-Xrw6kE7-rSOP1NRQaT3jAHWVVkhWz8c2oinYmQc+LrnjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Date: Sat, 11 Jun 2016 16:22:38 -0700

> As part of ethtool application, application is requesting  the drivers
> to provide the supported eeprom size to allocate memory buffer for
> getting complete dump.

And the right way to do that is the driver requests the eeprom info
with a buffer size of zero, then the driver fills in the size field
for what the size actually is.

Then the application can allocate the proper buffer size and rerun
the eeprom request.

Putting endless values for each and every eeprom type a device has is
just rediculous.

I'm not going to continue promoting this broken and unscalable scheme,
we have to fix this.
