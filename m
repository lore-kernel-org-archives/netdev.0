From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] remove claim balance_rr won't reorder on many to one
Date: Tue, 30 Oct 2007 18:08:19 -0700
Message-ID: <4727D583.90807@hp.com>
References: <200710301948.MAA04351@tardy.cup.hp.com> <5242.1193777750@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:47340 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751878AbXJaBIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 21:08:22 -0400
In-Reply-To: <5242.1193777750@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 	2- next worst is "balance-rr many slow" to "single fast", with
> the reordering rate generally being substantially lower than case #1 (it
> looked like your test showed about a 1% reordering rate, if I'm reading
> your data correctly).

The percentage of reordering for TCP is likely capped by its effect on the 
congestion window, limiting the number of outstanding segments.

rick jones
