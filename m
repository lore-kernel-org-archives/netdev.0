From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add server ip to encrypt cookie in fast open
Date: Sat, 10 Aug 2013 00:45:57 -0700 (PDT)
Message-ID: <20130810.004557.504732542861099769.davem@davemloft.net>
References: <1375995982-17862-1-git-send-email-ycheng@google.com>
	<CADVnQynQZDzefMWX868c46i0RkuRig=6By1B70a9=2GWTkcDfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968352Ab3HJHqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 03:46:00 -0400
In-Reply-To: <CADVnQynQZDzefMWX868c46i0RkuRig=6By1B70a9=2GWTkcDfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 8 Aug 2013 20:48:28 -0400

> On Thu, Aug 8, 2013 at 5:06 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> Encrypt the cookie with both server and client IPv4 addresses,
>> such that multi-homed server will grant different cookies
>> based on both the source and destination IPs. No client change
>> is needed since cookie is opaque to the client.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>>  include/net/tcp.h       |  3 ++-
>>  net/ipv4/tcp_fastopen.c | 13 ++++++-------
>>  net/ipv4/tcp_ipv4.c     | 10 +++++++---
>>  3 files changed, 15 insertions(+), 11 deletions(-)
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied to net-next, thanks everyone.
