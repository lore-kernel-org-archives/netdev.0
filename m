From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes
 down
Date: Thu, 17 Oct 2013 16:19:55 -0400 (EDT)
Message-ID: <20131017.161955.793695802575716229.davem@davemloft.net>
References: <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
	<alpine.LFD.2.03.1310172245440.2016@ssi.bg>
	<CAKfDRXiM-8dnGqFMofdiaD=EMJNLxzx-yhVManRSiQHgziuVdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762532Ab3JQUUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 16:20:02 -0400
In-Reply-To: <CAKfDRXiM-8dnGqFMofdiaD=EMJNLxzx-yhVManRSiQHgziuVdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Thu, 17 Oct 2013 22:11:39 +0200

> On Thu, Oct 17, 2013 at 9:52 PM, Julian Anastasov <ja@ssi.bg> wrote:
>>         IIRC, such notifications were not implemented
>> to avoid storms to routing daemons. Not sure if this is
>> still true.
> 
> Thanks for letting me know. I was wondering if this was the case, but
> then I saw that the deletion of IPv6 routes are announced (when
> running "ip link set dev X down") and assumed that message storms was
> (is?) not considered a problem.

I really wish IPV6 wouldn't be inconsistent and behave that way.
