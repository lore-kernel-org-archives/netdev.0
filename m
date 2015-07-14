From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stop endless flood about dst entry refcount
 underflow or overflow
Date: Tue, 14 Jul 2015 15:30:56 -0700 (PDT)
Message-ID: <20150714.153056.1150026369732009178.davem@davemloft.net>
References: <1436875454.1374.9.camel@edumazet-glaptop2.roam.corp.google.com>
	<55A4FD76.7050606@yandex-team.ru>
	<1436876767.1374.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khlebnikov@yandex-team.ru, netdev@vger.kernel.org,
	edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbbGNWa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 18:30:59 -0400
In-Reply-To: <1436876767.1374.13.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Jul 2015 14:26:07 +0200

> On Tue, 2015-07-14 at 15:15 +0300, Konstantin Khlebnikov wrote:
> 
>> Simple warn-once will hide a lot of information which could be useful.
>> Also dst entry leak is better than freeing actually active entry.
> 
> Then BUG_ON() .
> 
> Really, we need to fix leaks, not brown paper them.

No, killing the machine is not the answer.

If you want to rate limit this message, do it on a per-device basis,
but without corrupting the netdev state in the process.
