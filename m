From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: prevent unnecessary reordering
Date: Mon, 28 Apr 2008 16:39:46 +0200
Message-ID: <20080428143946.GA2870@ami.dom.local>
References: <20080428.020356.105209144.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:3348 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932432AbYD1Oln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 10:41:43 -0400
Received: by fg-out-1718.google.com with SMTP id l27so4969958fgb.17
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 07:41:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080428.020356.105209144.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 04/28/2008 11:03 AM:
...
>> [NET_SCHED] sch_sfq: prevent unnecessary reordering
>>
>> Current check of queue limit in sfq_enqueue() isn't optimal: there
>> is really not much more needed to prevent unnecessary dropping and
>> possible reordering.
>>
>>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> I'll let Patrick review this one first, too.

Very wise decision! (As usual.)

But, after rethinking, I've to withdraw this patch too. Sorry!

It looks like the patch could be quite right and should save sometimes
a few cpu cycles, but the subject and the comment are wrong: it doesn't
prevent reordering, but simply adding and later dropping the same
packet. So, the gain is less than planned. (Anyway, if somebody thinks
it's useful, I could resend it after changing...)

Thanks,
Jarek P.
