From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel
 state
Date: Thu, 27 Aug 2015 11:30:34 -0700 (PDT)
Message-ID: <20150827.113034.516720424389108762.davem@davemloft.net>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
	<20150823.165103.2104601245219561984.davem@davemloft.net>
	<20150826181926.0444240f@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554AbbH0Sae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 14:30:34 -0400
In-Reply-To: <20150826181926.0444240f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 26 Aug 2015 18:19:26 +0200

> Please let me know if you disagree with my analysis above.

I agree with your analysis, thanks for taking the time to investigate.

As for the %40 degradation, as Thomas mentioned it's because of the
extra FIB lookups.
