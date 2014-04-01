From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Tue, 1 Apr 2014 15:19:48 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C8A255E@CMEXMB1.ad.emulex.com>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C89CCDD@CMEXMB1.ad.emulex.com>
	<20140327.145336.1708122219432567015.davem@davemloft.net>
	<1395970770.2898.54.camel@deadeye.wl.decadent.org.uk>
 <20140328.171253.1863144825039621848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:34762 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaDAPTu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 11:19:50 -0400
In-Reply-To: <20140328.171253.1863144825039621848.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > By grouping the key and hash together, with some reserved fields
> > (which the setter should initially require to be equal to zero), it
> > should be possible to fill in support for numbered RSS contexts later
> > without yet another new structure and operations.


> If that is the case, why don't we add from the start a "u32 rss_context;"
> field that has to be set to zero for now?

The current structure has got three u32 reserved fields already. We could use one of them when the support is added.
