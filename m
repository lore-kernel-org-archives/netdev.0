From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 3/3] qlge: Add watchdog timer.
Date: Thu, 4 Feb 2010 08:04:27 -0800
Message-ID: <20100204160427.GA9938@linux-ox1b.qlogic.org>
References: <1265217853-26959-1-git-send-email-ron.mercer@qlogic.com> <1265217853-26959-4-git-send-email-ron.mercer@qlogic.com> <20100203.193222.64773800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8764 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504Ab0BDQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 11:11:22 -0500
Content-Disposition: inline
In-Reply-To: <20100203.193222.64773800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This does a PIO to the chip every single second?
> 
> How about something like 5 or 10 seconds, and use the
> deferrable interfaces so that it's more friendly to
> power management on an otherwise idle system?
>

You are correct that we don't need to check every second.
I will increase the duration and test it out a deferrable timer.

Thanks
