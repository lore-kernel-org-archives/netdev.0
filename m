From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: Set NOCARRIER bit of etherdev state at
 initialization
Date: Fri, 23 May 2014 14:15:51 -0400 (EDT)
Message-ID: <20140523.141551.1253983630587935706.davem@davemloft.net>
References: <537F7EEF.3060701@gmail.com>
	<1400866681.18322.27.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumaran.4353@gmail.com, stephen@networkplumber.org,
	avi.kp.137@gmail.com, edumazet@google.com, netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaEWSP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 14:15:57 -0400
In-Reply-To: <1400866681.18322.27.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Fri, 23 May 2014 12:38:01 -0500

> The current "carrier on until told otherwise" model is intentional,
> because not all drivers support carrier detection, and thus we must
> assume the carrier is on until the driver tells us it is not on.
> 
> Would this patch break that model?

Absolutely correct, this change is completely inappropriate.
