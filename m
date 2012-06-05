From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 43327] New: IP routing: cached route is applied to wrong
 network interface
Date: Tue, 05 Jun 2012 15:40:04 -0700 (PDT)
Message-ID: <20120605.154004.1635401933600568998.davem@davemloft.net>
References: <20120531174641.2809b5c4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117Ab2FEWkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 18:40:04 -0400
In-Reply-To: <20120531174641.2809b5c4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 31 May 2012 17:46:41 -0700

> Subject: [Bug 43327] New: IP routing: cached route is applied to wrong network interface

I suspect we'll need to root the inetpeer trees in the fib rules
to fix this.
