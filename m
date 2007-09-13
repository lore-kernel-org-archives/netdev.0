From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] [RFC] allow admin/users to specify rto_min in	milliseconds
 rather than jiffies
Date: Thu, 13 Sep 2007 09:56:24 -0700
Message-ID: <46E96BB8.6040202@hp.com>
References: <200709042020.NAA29612@tardy.cup.hp.com>	<20070905073801.2f12991b@oldman> <46E06E7C.4000407@hp.com>	<46E84BFA.2070101@hp.com> <20070913103957.5354ea5d@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:53090 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbXIMQ47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 12:56:59 -0400
In-Reply-To: <20070913103957.5354ea5d@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Your observations are correct. rtnetlink can't/shouldn't be doing conversions
> itself.  The 'ip' command should use a consistent unit for all values and
> do conversions if necessary.

That being the case I'll start looking to see what is involved in 
"leveraging" the time conversion stuff in tc for use in ip.

rick jones
