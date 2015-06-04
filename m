From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: inet_bind: check the addr_len first
Date: Wed, 03 Jun 2015 19:38:23 -0700 (PDT)
Message-ID: <20150603.193823.2127048807981229902.davem@davemloft.net>
References: <1433236080-5974-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43382 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbbFDCiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:38:24 -0400
In-Reply-To: <1433236080-5974-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Tue,  2 Jun 2015 12:08:00 +0300

> Perform the address length check first, before calling
> the the proto specific bind() function
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

This doesn't fix any actual bug, doesn't improve the code in
preparation for another change that actually benefits from
this adjustment, and so this is really an unwanted change.

This change and it's commit log message look totally arbitrary
and opaque, even to people who have been working with this
code and it's interfaces for decades.  That should tell you
something.

You have to let us know exactly why you are making a change, and what
real _actual_ bug it fixes, when you want us to consider your changes
seriously.

I'm not applying this, sorry.
