From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 20/21] forcedeth: fix locking bug with netconsole
Date: Fri, 28 Mar 2008 18:48:46 -0400
Message-ID: <47ED75CE.1080400@garzik.org>
References: <200803282141.m2SLfUwU011858@imap1.linux-foundation.org> <20080328.154353.43255092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, mingo@elte.hu,
	aabdulla@nvidia.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58451 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbYC1Wsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 18:48:53 -0400
In-Reply-To: <20080328.154353.43255092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Fri, 28 Mar 2008 14:41:30 -0700
> 
>> From: Ingo Molnar <mingo@elte.hu>
>>
>> While using netconsole on forcedeth, lockdep noticed the following locking
>> bug:
> 
> Please do not mix device driver changes with core networking
> changes.

FWIW my plan was to snip the net/* stuff and only apply the forcedeth 
portion.

(leaving <whomever> to pick up the pieces, should they so desire)

	Jeff



