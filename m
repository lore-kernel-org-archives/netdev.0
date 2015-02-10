From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: Rename sock_recv_ts_and_drops() to sock_cmsg_recv()
Date: Tue, 10 Feb 2015 14:57:11 +0200
Message-ID: <75B13C03-8E9F-4E70-9DAD-FFE187A3DF15@gmail.com>
References: <1423505723-2281-1-git-send-email-eyal.birger@gmail.com> <1423505723-2281-2-git-send-email-eyal.birger@gmail.com> <20150209.185535.1300672977479433508.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62590 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbBJM5M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 07:57:12 -0500
Received: by mail-wi0-f172.google.com with SMTP id z2so14237906wiv.5
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 04:57:11 -0800 (PST)
In-Reply-To: <20150209.185535.1300672977479433508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> On Feb 10, 2015, at 4:55 AM, David Miller <davem@davemloft.net> wrote:
> 
> From: Eyal Birger <eyal.birger@gmail.com>
> Date: Mon,  9 Feb 2015 20:15:21 +0200
> 
>> -void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
>> +void __sock_cmsg_recv(struct msghdr *msg, struct sock *sk,
>> 			      struct sk_buff *skb);
> 
> If you change the column where the openning parenthesis of a function
> declaration appears, you have to reindent the subsequent lines,
> if any, so that the arguments still begin at the first column after
> that openning parenthesis.

Sorry about that, thanks! Will fix.

> Also, this new feature is too late for this merge window, so there is
> no rush for resubmitting this.

Thanks. Should I wait for the next merge window or may I resubmit at this point?

Regards,
Eyal.