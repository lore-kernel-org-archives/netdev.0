From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Mon, 01 Jun 2015 14:39:38 -0700 (PDT)
Message-ID: <20150601.143938.949940905876752935.davem@davemloft.net>
References: <1433182033.6319.178.camel@decadent.org.uk>
	<556CAEA9.5090003@broadcom.com>
	<1433186963.6319.195.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aparames@broadcom.com, bwh@kernel.org, netdev@vger.kernel.org,
	jdzheng@broadcom.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbbFAVjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 17:39:39 -0400
In-Reply-To: <1433186963.6319.195.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 01 Jun 2015 20:29:23 +0100

> On Mon, 2015-06-01 at 12:12 -0700, Arun Parameswaran wrote:
>> But this prevents the 'ethtool' from being used to get/set data of
>> specific PHY's.
> 
> That is fine because it is meant to manage the net device's own link (in
> this case, the internal port), not other switch ports.

Ok I'm convinced, I will revert the change in question.

Thanks Ben.
