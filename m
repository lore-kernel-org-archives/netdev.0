From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 6/7] fib: hook IPv4 fib for hardware offload
Date: Thu, 05 Mar 2015 02:05:19 -0500 (EST)
Message-ID: <20150305.020519.1302163071820735824.davem@davemloft.net>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
	<1425425520-34017-7-git-send-email-sfeldma@gmail.com>
	<54F7FFD5.8080407@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53495 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbbCEHFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 02:05:21 -0500
In-Reply-To: <54F7FFD5.8080407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 04 Mar 2015 23:03:49 -0800

> Don't you need something to disable further fib entries from being
> added
> once you get a failure and flush the table? Maybe I'm just not seeing.
> 
> The case being you add a set of entries, you get a failure and flush
> the
> table then add another entry. The last entry is successfully inserted
> but now your out of sync.

Yes, he knows, we've been discussing exactly this problem.
