From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Thu, 20 Mar 2014 15:43:00 -0400 (EDT)
Message-ID: <20140320.154300.2088426765265988408.davem@davemloft.net>
References: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
	<20140319.155930.1805664690676428310.davem@davemloft.net>
	<BF3270C86E8B1349A26C34E4EC1C44CB2C8968A5@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk
To: VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50809 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759747AbaCTTnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 15:43:02 -0400
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C8968A5@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Date: Thu, 20 Mar 2014 12:02:11 +0000

> It went through many changes later with the intention of combining
> both indirection and hash key setting into one option as both are
> related to rss configuration.

Combining these two things makes the buffer management at the end of
the defined data type more complex.

Furthermore, we generally steer far away from having multiple ways
to do the same exact thing.
