From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v3 0/7] TCP Fast Open client
Date: Thu, 19 Jul 2012 11:26:01 -0700
Message-ID: <CAK6E8=c+qCmXeF8ByFnhk9ZPBYLb08A=GJPXnGY7aVnAKWnn0A@mail.gmail.com>
References: <1342716191-19196-1-git-send-email-ycheng@google.com> <20120719.105616.2007996793203344140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hkchu@google.com, edumazet@google.com, ncardwell@google.com,
	sivasankar@cs.ucsd.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:57443 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab2GSS0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 14:26:23 -0400
Received: by qcro28 with SMTP id o28so1906571qcr.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 11:26:22 -0700 (PDT)
In-Reply-To: <20120719.105616.2007996793203344140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 19, 2012 at 10:56 AM, David Miller <davem@davemloft.net> wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Thu, 19 Jul 2012 09:43:04 -0700
>
>> ChangeLog since v2:
>>   - Added seqlock to update Fast Open metrics
>>   - Move TCP magic code in inet_wait_for_connect() to inet_stream_connect()
>>   - Move up MSG_FASTOPEN macro for better header formatting
>>
>> ChangeLog since v1:
>>   - Reduce tons of code by storing Fast Open stats in the TCP metrics :)
>>   - Clarify the purpose of using an experimental option in patch 1/7
>
> Ok I've applied this series and am doing build testing, if nothing
> falls out from that I'll push it out to net-next.
>
> Thanks a lot for doing this work.
And a big THANK YOU for taking this patch too. I hope it works. :)
