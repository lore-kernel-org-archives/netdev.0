From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 43327] New: IP routing: cached route is applied to wrong
 network interface
Date: Tue, 12 Jun 2012 13:39:05 -0700 (PDT)
Message-ID: <20120612.133905.111728727958886749.davem@davemloft.net>
References: <20120531174641.2809b5c4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab2FLUjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 16:39:06 -0400
In-Reply-To: <20120531174641.2809b5c4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 31 May 2012 17:46:41 -0700

> https://bugzilla.kernel.org/show_bug.cgi?id=43327
> 
>            Summary: IP routing: cached route is applied to wrong network
>                     interface

This should now be fixed in net-next, inetpeer trees are rooted in the
FIB rules, so should handle arbitrary route lookup key situations.
