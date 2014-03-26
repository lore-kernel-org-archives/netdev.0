From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Wed, 26 Mar 2014 09:21:01 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C89CCDD@CMEXMB1.ad.emulex.com>
References: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
	<20140319.155930.1805664690676428310.davem@davemloft.net>
	<1395412393.2770.48.camel@deadeye.wl.decadent.org.uk>
 <20140321.152836.1010161671166010422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:27124 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbaCZJVE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 05:21:04 -0400
In-Reply-To: <20140321.152836.1010161671166010422.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Nothing stops ethtool from providing a combined operation on the command
> line, but that doesn't mean we necessarily have to have a single kernel
> interface doing both thing.

Sounds good. We can have a combined operation on the command line and can still have different data structure, command and kernel interface for each of the sub operations.

> I really still think that adding just a new key operation is the way to go.

Ben and David,
I don't mind going back to the original approach of adding a new hash key operation. Please let me know what you guys think, combined operation or a new operation.
