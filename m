From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix no cwnd growth after timeout
Date: Fri, 06 Sep 2013 14:47:13 -0400 (EDT)
Message-ID: <20130906.144713.1644793877385608777.davem@davemloft.net>
References: <1378420569-12370-1-git-send-email-ycheng@google.com>
	<CADVnQynvfPtsJN-XqpTkbu4Y+=uzYcmv22GpaV=tRYL8w90TUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751060Ab3IFSrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:47:15 -0400
In-Reply-To: <CADVnQynvfPtsJN-XqpTkbu4Y+=uzYcmv22GpaV=tRYL8w90TUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 5 Sep 2013 19:56:59 -0400

> On Thu, Sep 5, 2013 at 6:36 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> In commit 0f7cc9a3 "tcp: increase throughput when reordering is high",
>> it only allows cwnd to increase in Open state. This mistakenly disables
>> slow start after timeout (CA_Loss). Moreover cwnd won't grow if the
>> state moves from Disorder to Open later in tcp_fastretrans_alert().
>>
>> Therefore the correct logic should be to allow cwnd to grow as long
>> as the data is received in order in Open, Loss, or even Disorder state.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> 
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thank you.
