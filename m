From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv4: fib: check forwarding before checking
 send_redirects
Date: Tue, 08 Apr 2014 18:04:03 -0400 (EDT)
Message-ID: <20140408.180403.2032592427150449635.davem@davemloft.net>
References: <CAM_iQpXrmRNhQCWjiRSKwzxvtcq9XuT-cWS4vRxYVYxpUEN3qQ@mail.gmail.com>
	<20140408.172343.917107273854891906.davem@davemloft.net>
	<CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, ja@ssi.bg,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756232AbaDHWEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 18:04:07 -0400
In-Reply-To: <CAM_iQpXkmU9qw_KPeMPnE0KGbcCWo5R=Le7HsizyiuRJVkKshA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 8 Apr 2014 14:50:09 -0700

> Which part am I missing?

Please stop looking at this conditional, I'm begging you.

Instead, concentrate on why __fib_validate_source() is rejecting
your packets.

The code must function correctly even if __fib_validate_source()
is invoked unconditionally, all the time, for all non-IPSEC
packets.
