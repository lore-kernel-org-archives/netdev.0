From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch v2] bnx2x: Add run-time CNIC support
Date: Tue, 10 Jul 2012 06:06:16 -0700 (PDT)
Message-ID: <20120710.060616.2081630953053267615.davem@davemloft.net>
References: <1341923634.27035.6.camel@lb-tlvb-eilong.il.broadcom.com>
	<20120710.053724.1002197670026212780.davem@davemloft.net>
	<1341924089.27035.7.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880Ab2GJNGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 09:06:18 -0400
In-Reply-To: <1341924089.27035.7.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Tue, 10 Jul 2012 15:41:29 +0300

> OK. Since it blocks the ability to add SR-IOV support, is it acceptable
> to submit it as constant enabled for PF and disabled for VF (SR-IOV)?

You're not describing to me why you guys are turning on features like
the CNIC mode before you necessarily have any users of that feature.

Why can't you turn CNIC off at the start, and if a CNIC user actually
arrives and is activated, reset the entire chip and put it into CNIC
mode?

And if CNIC being on is such a latency killer, why in the world
haven't you done things more reasonably like that from the very
beginning?

Why are you making it so that lower latency with your chips is only
available to a group of users who are effectively statistically
insignificant?
