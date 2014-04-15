From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 1/3] net: move LOOPBACK_IFINDEX to include/net/flow.h
Date: Tue, 15 Apr 2014 12:13:13 -0700
Message-ID: <CAM_iQpULd0bLfLJbwJn3GkbChGMrxbd9Nq4v7mamBUjXpqx+ZQ@mail.gmail.com>
References: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140415.150600.1198094454060493410.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:45371 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754737AbaDOTNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 15:13:14 -0400
Received: by mail-ob0-f173.google.com with SMTP id wn1so3755866obc.18
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 12:13:13 -0700 (PDT)
In-Reply-To: <20140415.150600.1198094454060493410.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 12:06 PM, David Miller <davem@davemloft.net> wrote:
>
> Cong, first of all, I'd like you to combine patches #1 and #2.
>

OK, whatever you prefer...I have no strong opinion here.

> Also, Julian made it clear that several other changes needed happen
> besides the single fib_validate_source() call site you are modifying
> in patch #3.
>
> He also said, for example, that the flow4_iif assignment in
> __fib_validate_source() needs adjusting as well.
>
> He furthermore said that other assignments of zero to flow4_iif
> in netfilter and elsewhere must be adjusted as well.

I believe I did in patch #2, or I still miss anything?

>
> Please also provide a proper 0/N patch posting next time explaining
> exactly what the series does and why it is necessary.

OK, will do, I thought per-patch description is enough.

Thanks.
