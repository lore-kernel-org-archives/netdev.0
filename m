From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.22] TCP: Make TCP_RTO_MAX a variable (take 2)
Date: Mon, 23 Jul 2007 11:40:00 -0700
Message-ID: <46A4F600.90403@hp.com>
References: <46969CA9.8030406@hp.com>	<Pine.LNX.4.64.0707130726550.30150@kivilampi-30.cs.helsinki.fi>	<4697AE6E.4070600@hp.com> <20070713.231926.74749058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, shemminger@linux-foundation.org,
	noboru.obata.ar@hitachi.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:49927 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762833AbXGWTOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 15:14:19 -0400
In-Reply-To: <20070713.231926.74749058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 13 Jul 2007 09:55:10 -0700
> 
> 
>>Fine, but so?  I suspect the point of the patch is to provide a
>>lower cap on the accumulated backoff so data starts flowing over the
>>connection within that lower cap once the link is
>>restored/failed-over.
> 
> 
> The backoff is there for a reason.

I'm not disputing the general value of the backoff, nor about the value of an 
initial value of 60 seconds.  In terms of avoiding congestive collapse one does 
indeed want the exponential backoff.  I'm just in agreement with the person from 
Hitachi that allowing someone to tweak the backoff has a certain value.

60 seconds is already a trade-off between a pure (non capped) exponential 
backoff and capping the value.

rick
