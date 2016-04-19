From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv3 net-next] net: use jiffies_to_msecs to replace
 EXPIRES_IN_MS in inet/sctp_diag
Date: Tue, 19 Apr 2016 20:37:20 +0800
Message-ID: <CADvbK_frX94W9gogBkMUdyQP=ta-QmV5RxewT9AE+AG14aMbmw@mail.gmail.com>
References: <87a0e83132ce64a3fe2266a5323fa6577a2e5c96.1461049801.git.lucien.xin@gmail.com>
	<1461068732.10638.169.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>, jsitnick@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35984 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbcDSMhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 08:37:21 -0400
In-Reply-To: <1461068732.10638.169.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2016 at 8:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-04-19 at 15:10 +0800, Xin Long wrote:
>> EXPIRES_IN_MS macro comes from net/ipv4/inet_diag.c and dates
>> back to before jiffies_to_msecs() has been introduced.
>>
>> Now we can remove it and use jiffies_to_msecs().
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> ---
>
> Ok. Note that you could have mentioned this was
>
> Suggested-by: Jakub Sitnicki <jkbs@redhat.com>
>
> Even coworkers deserve credits ;)
yeah, didn't know the tag "Suggested-by:" before.
Thanks. :D

>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Thanks.
>
>
>
