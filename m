From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Remove redundant oif checks in
 rt6_device_match
Date: Mon, 28 Sep 2015 22:30:53 -0700 (PDT)
Message-ID: <20150928.223053.1568032481735754170.davem@davemloft.net>
References: <1443216174-72579-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbbI2Fay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:30:54 -0400
In-Reply-To: <1443216174-72579-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 25 Sep 2015 15:22:54 -0600

> The oif has already been checked that it is non-zero; the 2 additional
> checks on oif within that if (oif) {...} block are redundant.
> 
> CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Looks good, applied, thanks.
