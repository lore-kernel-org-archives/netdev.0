From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 11:01:52 -0700 (PDT)
Message-ID: <20120720.110152.1959842625155766788.davem@davemloft.net>
References: <1342796553.2626.7389.camel@edumazet-glaptop>
	<CAK6E8=dkwruGMtW2uQ--xZ_so9aZQt-KcmHsy2yE5GApKphrJQ@mail.gmail.com>
	<CADVnQymoWQmdtTEv_KOvHbQvC6oC0EsJvhda5oAf7CVithS3Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	therbert@google.com, shemminger@vyatta.com, johnwheffner@gmail.com,
	nanditad@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab2GTSBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:01:53 -0400
In-Reply-To: <CADVnQymoWQmdtTEv_KOvHbQvC6oC0EsJvhda5oAf7CVithS3Pg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Fri, 20 Jul 2012 10:58:27 -0700

> On Fri, Jul 20, 2012 at 8:07 AM, Yuchung Cheng <ycheng@google.com> wrote:
>> On Fri, Jul 20, 2012 at 8:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> When/if sysctl_tcp_abc > 1, we expect to increase cwnd by 2 if the
>>> received ACK acknowledges more than 2*MSS bytes, in tcp_slow_start()
>>>
>>> Problem is this RFC 3465 statement is not correctly coded, as
>>> the while () loop increases snd_cwnd one by one.
>>>
>>> Add a new variable to avoid this off-by one error.
>>>
>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Acked-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied.
