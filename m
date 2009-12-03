From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/4] be2net: Add support for ethtool self
 test
Date: Thu, 03 Dec 2009 13:16:06 -0800 (PST)
Message-ID: <20091203.131606.107274637.davem@davemloft.net>
References: <20091203161804.GA1382@serverengines.com>
	<20091203.124016.226739840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755076AbZLCVQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:16:00 -0500
In-Reply-To: <20091203.124016.226739840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 03 Dec 2009 12:40:16 -0800 (PST)

> From: Ajit Khaparde <ajitk@serverengines.com>
> Date: Thu, 3 Dec 2009 21:48:14 +0530
> 
>> This patch adds support for ethtool selftest.
>> 
>> From: Suresh R <sureshr@serverengines.com>
>> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
> 
> Applied.

This breaks the build, there is no ->self_test_count member
of ethtool_ops.

I'm reverting just this change.
